#!/usr/bin/env bash

nomad job run ./job.hcl

export VAULT_ADDR="http://127.0.0.1:8200"
if [ -f ./artifacts/init.json ]; then
  export VAULT_TOKEN=$(jq -r .root_token ./artifacts/init.json)
fi

vault status

# VAULT_INIT=$(VAULT_ADDR=http://127.0.0.1:8200 vault operator init -format=json)
# echo $VAULT_INIT
# VAULT_UNSEAL_KEYS=$(echo $VAULT_INIT | jq -r .unseal_keys_b64)
# echo $VAULT_UNSEAL_KEYS
# VAULT_ROOT_TOKEN=$(echo $VAULT_INIT | jq -r .root_token)
# echo $VAULT_ROOT_TOKEN
