#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/../../artifacts}"
mkdir -p $ARTIFACTS_DIR

KV_PATH=nomad

CONFIG_DIR="/etc/nomad.d"
DATA_DIR="/opt/nomad/data"

consul kv put $KV_PATH/core/config_dir $CONFIG_DIR
consul kv put $KV_PATH/core/data_dir $DATA_DIR

GOSSIP_KEY=$(nomad operator gossip keyring generate)

consul kv put $KV_PATH/gossip/key $GOSSIP_KEY

pushd $ARTIFACTS_DIR

nomad tls ca create
consul kv put $KV_PATH/tls/ca_cert @nomad-agent-ca.pem
consul kv put $KV_PATH/tls/ca_key @nomad-agent-ca-key.pem

nomad tls cert create -server
consul kv put $KV_PATH/tls/server_cert @global-server-nomad.pem
consul kv put $KV_PATH/tls/server_key @global-server-nomad-key.pem

nomad tls cert create -client
consul kv put $KV_PATH/tls/client_cert @global-client-nomad.pem
consul kv put $KV_PATH/tls/client_key @global-client-nomad-key.pem

rm -f *.pem
popd

sudo consul-template -config ./templates.hcl -once
sudo chown -R nomad:nomad $(consul kv get $KV_PATH/core/config_dir)

sudo systemctl enable nomad.service
sudo systemctl restart nomad.service
sleep 15s

export NOMAD_ADDR="http://127.0.0.1:4646"

if [ -z $(consul kv get -keys $KV_PATH/acl) ]; then
  BOOTSTRAP_TOKEN=$(nomad acl bootstrap -json | jq -r .SecretID)

  consul kv put $KV_PATH/acl/bootstrap_token $BOOTSTRAP_TOKEN
fi

source ../../core/env.sh

nomad server members
nomad node status

popd
