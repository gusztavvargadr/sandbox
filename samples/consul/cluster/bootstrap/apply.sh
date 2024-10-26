#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/../artifacts}"
mkdir -p $ARTIFACTS_DIR

pushd ../core
docker compose up -d
sleep 5s
popd

export CONSUL_HTTP_ADDR="http://127.0.0.1:58500"
KV_PATH=consul

CONFIG_DIR="/etc/consul.d"
DATA_DIR="/opt/consul/data"

consul kv put $KV_PATH/core/config_dir $CONFIG_DIR
consul kv put $KV_PATH/core/data_dir $DATA_DIR

GOSSIP_KEY=$(consul keygen)

consul kv put $KV_PATH/gossip/key $GOSSIP_KEY

pushd $ARTIFACTS_DIR

consul tls ca create
consul kv put $KV_PATH/tls/ca_cert @consul-agent-ca.pem
consul kv put $KV_PATH/tls/ca_key @consul-agent-ca-key.pem

consul tls cert create -server
consul kv put $KV_PATH/tls/server_cert @dc1-server-consul-0.pem
consul kv put $KV_PATH/tls/server_key @dc1-server-consul-0-key.pem

rm -f *.pem
popd

sudo CONSUL_HTTP_ADDR=$CONSUL_HTTP_ADDR consul-template -config ./templates.hcl -once
sudo chown -R consul:consul $(consul kv get $KV_PATH/core/config_dir)

sudo systemctl enable consul.service
sudo systemctl restart consul.service
sleep 5s

export CONSUL_HTTP_ADDR="http://127.0.0.1:8500"
unset CONSUL_HTTP_TOKEN

BOOTSTRAP_TOKEN=$(consul acl bootstrap -format=json | jq -r .SecretID)
export CONSUL_HTTP_TOKEN=$BOOTSTRAP_TOKEN
consul acl set-agent-token agent $BOOTSTRAP_TOKEN
consul acl set-agent-token default $BOOTSTRAP_TOKEN
unset CONSUL_HTTP_TOKEN

consul members

CONSUL_SERVERS=$(consul members -status alive | awk 'NR>1 {print "\""$2"\""}' | paste -sd ',')

export CONSUL_HTTP_ADDR="http://127.0.0.1:58500"

consul kv put $KV_PATH/acl/bootstrap_token $BOOTSTRAP_TOKEN
consul kv put $KV_PATH/acl/agent_token_agent $BOOTSTRAP_TOKEN
consul kv put $KV_PATH/acl/agent_token_default $BOOTSTRAP_TOKEN

consul kv put $KV_PATH/servers/addresses $CONSUL_SERVERS

consul kv export $KV_PATH > $ARTIFACTS_DIR/kv.json

popd

# consul acl policy create -name agent-agent -rules @policy.agent-agent.hcl
# CONSUL_ACL_AGENT_AGENT_TOKEN=$(consul acl token create -policy-name agent-agent -format=json | jq -r .SecretID)
# consul acl set-agent-token agent $CONSUL_ACL_AGENT_AGENT_TOKEN

# consul acl policy create -name agent-default -rules @policy.agent-default.hcl
# CONSUL_ACL_AGENT_DEFAULT_TOKEN=$(consul acl token create -policy-name agent-default -format=json | jq -r .SecretID)
# consul acl set-agent-token default $CONSUL_ACL_AGENT_DEFAULT_TOKEN

# --

# agent_prefix "" {
#   policy = "write"
# }

# node_prefix "" {
#   policy = "write"
# }

# service_prefix "" {
#   policy = "read"
# }

# session_prefix "" {
#   policy = "read"
# }

# --

# node_prefix "" {
#   policy = "read"
# }

# service_prefix "" {
#   policy = "read"
# }
