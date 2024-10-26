#!/usr/bin/env bash

VAULT_MOUNT=kv/nomad

CONFIG_DIR="/etc/nomad.d"
DATA_DIR="/opt/nomad/data"
DATACENTER="dc1"

vault kv put $VAULT_MOUNT/core \
  config_dir=$CONFIG_DIR \
  data_dir=$DATA_DIR \
  datacenter=$DATACENTER \

GOSSIP_KEY=$(nomad operator gossip keyring generate)

vault kv put $VAULT_MOUNT/gossip \
  key=$GOSSIP_KEY

mkdir -p ./artifacts/tls
rm -Rf ./artifacts/tls/*
pushd ./artifacts/tls

nomad tls ca create
TLS_CA_CERT=$(base64 -w 0 nomad-agent-ca.pem)
TLS_CA_KEY=$(base64 -w 0 nomad-agent-ca-key.pem)

nomad tls cert create -server
TLS_SERVER_CERT=$(base64 -w 0 global-server-nomad.pem)
TLS_SERVER_KEY=$(base64 -w 0 global-server-nomad-key.pem)

nomad tls cert create -client
TLS_CLIENT_CERT=$(base64 -w 0 global-client-nomad.pem)
TLS_CLIENT_KEY=$(base64 -w 0 global-client-nomad-key.pem)

vault kv put $VAULT_MOUNT/tls \
  ca_cert=$TLS_CA_CERT \
  ca_key=$TLS_CA_KEY \
  server_cert=$TLS_SERVER_CERT \
  server_key=$TLS_SERVER_KEY \
  client_cert=$TLS_CLIENT_CERT \
  client_key=$TLS_CLIENT_KEY

popd
# rm -Rf ./artifacts
