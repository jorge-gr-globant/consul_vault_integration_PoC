#!/bin/bash
function register_service_config_json () {
  local NAME=$1
  local PORT=$2
  local CONTAINER_SOURCE=$3
  local FULL_PATH=/usr/${NAME}.json
  docker cp ./templates/consul_service.json fox:$FULL_PATH
  docker exec fox sed -i s/PORT/${PORT}/g $FULL_PATH
  docker exec fox sed -i s/NAME/${NAME}/g $FULL_PATH
  COUNTING_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_SOURCE)
  docker exec fox sed -i s/IP/${COUNTING_IP}/g $FULL_PATH
  docker exec -e CONSUL_HTTP_TOKEN=b6bd58da-5d14-11ea-b638-a0a4c567dbd5 fox consul services register  $FULL_PATH
}

function add_dns_entry () {
  local CONTAINER_NAME=$1
  local DNS_IP=$2
  docker exec -e DNS_IP=$DNS_IP $CONTAINER_NAME sh -c 'echo "nameserver $DNS_IP" > /etc/resolv.conf'
}

function sanitize_string() {
  local clean_str=$(printf "%s" "$1" | tr -d '[:space:]' | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g")
  printf "%s" "$clean_str" 
}

function init_consul_acl() {
  readonly local TOKEN=$1
  docker exec -it -e CONSUL_HTTP_TOKEN=$TOKEN badger sh -c  'consul acl policy list &> /dev/null; exit $?'
  VALUE=$?
  while [ $VALUE -ne 0 ]; do
          docker exec -it -e CONSUL_HTTP_TOKEN=$TOKEN badger sh -c  'consul acl policy list &> /dev/null; exit $?'
          VALUE=$?
    echo "Waiting until consul acl is ready"
  done
}

function create_consul_policy() {
  readonly local TOKEN_2=$1
  readonly local NAME=$2
  readonly local DESCR=$3
  readonly local POLICY_PATH=$4
  readonly local CONTAINER_NAME=$5
  local POLICY_TOKEN=$(docker exec -it -e CONSUL_HTTP_TOKEN=$TOKEN_2 -e NAME="$NAME" -e DESCR="$DESCR" -e POLICY_PATH="$POLICY_PATH" $5 sh -c 'consul acl policy create -name "${NAME}-policy" -description "$DESCR Policy" -rules @$POLICY_PATH && consul acl token create -description "$DESCR" -policy-name "${NAME}-policy"' | grep -Po 'SecretID:\s*\K[0-9a-z-]*' )
  printf "%s" $POLICY_TOKEN
}

function unseal_vault() {
  readonly local VAULT_OUTPUT=$(docker exec -it vault sh -c 'vault operator init')
  readonly local VAULT_TOKEN=$(sanitize_string $(printf "%s" "$VAULT_OUTPUT" | grep -Po 'Initial Root Token: \K.*' ))
  readarray KEY_ARR <<< "$(echo "$VAULT_OUTPUT" | grep -Po 'Unseal Key [0-9]+: \K.*')"
  for key in "${KEY_ARR[@]}";do
    clean_key=$(sanitize_string $key)
    UNSEAL_OUTPUT=$(docker exec -it -e KEY=$clean_key vault sh -c 'vault operator unseal $KEY')
    echo "$UNSEAL_OUTPUT" | grep -e 'Sealed \s* false' 2&>1 /dev/null
    if [ $? -eq 0 ]
    then
      break
    fi
  done
  printf "%s" "$VAULT_TOKEN"
}

CONSUL_ROOT_TOKEN=b6bd58da-5d14-11ea-b638-a0a4c567dbd5

docker-compose up -d 

CONSUL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' badger)
# Add dns entry in python app
add_dns_entry cat $CONSUL_IP

## REDIS ##
# Populate Redis with some keys
docker exec rabbit sh -c 'cat /usr/commands.txt | redis-cli'
## CONSUL ##
# Wait until acl is ready
init_consul_acl $CONSUL_ROOT_TOKEN
# Register the counting service
register_service_config_json counting 9001 weasel
# Create the agent policy and its token
AGENT_TOKEN=$(create_consul_policy $CONSUL_ROOT_TOKEN "agent-token" "Agent Token" "/usr/agent-policy.hcl" badger)
# Add the agent token in the server config
UPDATED_CONFIG=$(docker exec badger cat /consul/config/config.json | jq --arg agent $AGENT_TOKEN '.acl.tokens += {agent: $agent}')
# Update the config in the consul server
docker exec -e UPDATED_CONFIG="$UPDATED_CONFIG" badger sh -c 'echo "$UPDATED_CONFIG" > /consul/config/config.json'
docker exec -it -e CONSUL_HTTP_TOKEN=$CONSUL_ROOT_TOKEN badger sh -c 'consul reload'
# Update the config in the consul client
UPDATED_CONFIG=$(docker exec fox cat /consul/config/agent.json | jq --arg agent $AGENT_TOKEN '.acl.tokens += {agent: $agent}')
docker exec -e UPDATED_CONFIG="$UPDATED_CONFIG" fox sh -c 'echo "$UPDATED_CONFIG" > /consul/config/agent.json'
docker exec -it -e CONSUL_HTTP_TOKEN=$CONSUL_ROOT_TOKEN fox sh -c 'consul reload'
# Create a policy and a token for python kv store
PYTHON_KV_TOKEN=$(create_consul_policy $CONSUL_ROOT_TOKEN "python-kv" "Token for Python Kv Store" "/usr/python-kv.hcl" fox)
# Create some keys for python kv
docker exec -it -e CONSUL_HTTP_TOKEN=$CONSUL_ROOT_TOKEN fox sh -c 'consul kv put python/key1 value1'
docker exec -e KV_TOKEN=$PYTHON_KV_TOKEN cat sh -c 'echo KV_TOKEN=$KV_TOKEN > /src/.env'
docker-compose restart python_app
# Consul policy for vault
CONSUL_VAULT_TOKEN=$(create_consul_policy $CONSUL_ROOT_TOKEN "vault-policy" "Vault Policy" "/usr/vault-policy.hcl" badger)
## VAULT ##
# Update vault configuration for consul storage
VAULT_CONFIG=$(docker exec vault cat /vault/config/config.json | jq --arg token $CONSUL_VAULT_TOKEN --arg address "${CONSUL_IP}:8500" '.storage[0].consul += {token: $token, address: $address}')
docker exec -e VAULT_CONFIG="$VAULT_CONFIG" vault sh -c 'echo "$VAULT_CONFIG" > /vault/config/config.json'
docker-compose restart vault
## Unseal vault
VAULT_ROOT_TOKEN=$(unseal_vault)
docker exec -it -e VAULT_TOKEN=$VAULT_ROOT_TOKEN vault sh -c 'vault secrets enable -path=kv kv-v2; vault kv put kv/python/test hello=world; vault auth enable approle; vault policy write python /usr/python-policy.hcl; vault write auth/approle/role/python token_policies="python" token_ttl=0 token_max_ttl=0 secret_id_ttl=""'
readonly ROLE_ID_TOKEN=$(sanitize_string $(docker exec -it -e VAULT_TOKEN=$VAULT_ROOT_TOKEN vault vault read auth/approle/role/python/role-id | awk '{ if ($1 == "role_id")  print $2 }'))
readonly VAULT_APPROLE_SECRET_ID=$(sanitize_string $(docker exec -it -e VAULT_TOKEN=$VAULT_ROOT_TOKEN vault vault write -f auth/approle/role/python/secret-id | awk '{ if ($1 == "secret_id")  print $2 }'))
readonly PYTHON_APPROLE_TOKEN=$(docker exec -it -e VAULT_TOKEN=$VAULT_ROOT_TOKEN vault vault write auth/approle/login role_id="$ROLE_ID_TOKEN" secret_id="$VAULT_APPROLE_SECRET_ID" | awk '{ if ($1 == "token")  print $2 }')

VAULT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vault)
### Configure vault support for jenkins
docker exec -it jenkins sed -i "s/VAULT_TOKEN/$PYTHON_APPROLE_TOKEN/g" /var/jenkins_home/jenkins.yaml
docker-compose restart jenkins
printf "TOKENS: \n"
printf "CONSUL ROOT TOKEN: %s\n" $CONSUL_ROOT_TOKEN
printf "CONSUL AGENT TOKEN: %s\n" $AGENT_TOKEN
printf "CONSUL VAULT POLICY TOKEN: %s\n" $CONSUL_VAULT_TOKEN
printf "CONSUL PYTHON POLICY TOKEN: %s\n" $PYTHON_KV_TOKEN
printf "VAULT ROOT TOKEN: %s\n" $VAULT_ROOT_TOKEN
printf "VAULT PYTHON TOKEN: %s\n" $PYTHON_APPROLE_TOKEN
