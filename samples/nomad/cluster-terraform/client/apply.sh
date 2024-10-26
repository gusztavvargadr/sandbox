#!/usr/bin/env bash

VAULT_MOUNT=kv/nomad

pushd ..

SERVER_JOIN=$(terraform output -json | jq -r '.server_instances.value | map(.private_ip) | join(",")')
vault kv put $VAULT_MOUNT/server \
  join=$SERVER_JOIN

popd

consul-template -config templates.hcl -once
