# https://learn.hashicorp.com/vault/developer/iam-authentication
# vault policy write python python-policy.hcl
# vault write auth/approle/role/python token_policies="python" token_ttl=1h token_max_ttl=4h
# vault read auth/approle/role/python
# vault read auth/approle/role/python/role-id
# vault write -f auth/approle/role/python/secret-id
# vault write auth/approle/login role_id="<RID>" secret_id="<SID>"
path "kv/data/python*" {
  capabilities = [ "read" ]
}
