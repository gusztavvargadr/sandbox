#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/../artifacts}"

pushd ../core
docker compose up -d
sleep 5s
popd

consul kv import @$ARTIFACTS_DIR/kv.json  

KV_PATH=nomad

sudo consul-template -config ./templates.hcl -once
sudo chown -R nomad:nomad $(consul kv get $KV_PATH/core/config_dir)

sudo systemctl enable nomad.service
sudo systemctl restart nomad.service
sleep 15s

source ../core/env.sh

nomad server members
nomad node status
nomad status

NOMAD_SERVERS=$(nomad server members -json | jq -r -c [.[].Addr])
consul kv put $KV_PATH/servers/addresses $NOMAD_SERVERS

consul kv export $KV_PATH > $ARTIFACTS_DIR/kv.json

popd
