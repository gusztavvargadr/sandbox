#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

KV_PATH=nomad

sudo consul-template -config ./templates.hcl -once
sudo chown -R nomad:nomad $(consul kv get $KV_PATH/core/config_dir)

sudo systemctl enable nomad.service
sudo systemctl restart nomad.service
sleep 15s

source ../../core/env.sh

nomad server members
nomad node status

popd
