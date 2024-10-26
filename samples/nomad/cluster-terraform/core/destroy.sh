#!/usr/bin/env bash

VAULT_MOUNT=kv/nomad
vault kv metadata delete ${VAULT_MOUNT}/core
vault kv metadata delete ${VAULT_MOUNT}/gossip
vault kv metadata delete ${VAULT_MOUNT}/tls
vault kv metadata delete ${VAULT_MOUNT}/acl
vault kv metadata delete ${VAULT_MOUNT}/server

rm -Rf ./artifacts
