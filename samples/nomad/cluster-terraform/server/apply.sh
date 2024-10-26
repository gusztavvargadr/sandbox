#!/usr/bin/env bash

VAULT_MOUNT=kv/nomad

pushd ..

ACL_BOOTSTRAP_TOKEN=$(terraform output -json | jq -r .bootstrap_token.value.SecretID)
vault kv put $VAULT_MOUNT/acl \
  bootstrap_token=$ACL_BOOTSTRAP_TOKEN

SERVER_JOIN=$(terraform output -json | jq -r '.bootstrap_instances.value | map(.private_ip) | join(",")')
vault kv put $VAULT_MOUNT/server \
  join=$SERVER_JOIN

popd

consul-template -config templates.hcl -once
