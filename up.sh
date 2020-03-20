#!/bin/bash

function register_service_config_json () {
  local NAME=$1
  local PORT=$2
  local CONTAINER_SOURCE=$3
  docker cp ./templates/consul_service.json fox:/consul/config/${NAME}.json
  docker exec fox sed -i s/PORT/${PORT}/g /consul/config/${NAME}.json
  docker exec fox sed -i s/NAME/${NAME}/g /consul/config/${NAME}.json
  COUNTING_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_SOURCE)
  docker exec fox sed -i s/IP/${COUNTING_IP}/g /consul/config/${NAME}.json
  docker exec fox consul reload
}

function add_dns_entry () {
  local CONTAINER_NAME=$1
  local DNS_IP=$2
  docker exec -e DNS_IP=$DNS_IP $CONTAINER_NAME sh -c 'echo "nameserver $DNS_IP" > /etc/resolv.conf'
}

docker-compose up --build -d

register_service_config_json counting 9001 weasel

CONSUL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' badger)
# Add dns entry in python app
add_dns_entry cat $CONSUL_IP


# Populate Redis with some keys
docker exec rabbit sh -c 'cat /usr/commands.txt | redis-cli'

# Populate Consul with some keys
docker exec badger sh -c 'consul kv import @/usr/values.json'
