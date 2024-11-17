#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/../../artifacts}"

pushd ../../core
docker compose up -d
sleep 5s
popd

export CONSUL_HTTP_ADDR="http://127.0.0.1:58500"
consul kv import @$ARTIFACTS_DIR/kv.json  

KV_PATH=consul

sudo CONSUL_HTTP_ADDR=$CONSUL_HTTP_ADDR consul-template -config ./templates.hcl -once
sudo chown -R consul:consul $(consul kv get $KV_PATH/core/config_dir)

sudo systemctl enable consul.service
sudo systemctl restart consul.service
sleep 5s

export CONSUL_HTTP_ADDR="http://127.0.0.1:8500"

consul members

pushd ../../core
docker compose down --rmi all --volumes
popd

popd
