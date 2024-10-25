#!/usr/bin/env bash

set -euo pipefail

KV_PATH=nomad

export NOMAD_ADDR="http://127.0.0.1:4646"

if [ ! -z $(consul kv get -keys $KV_PATH/acl) ]; then
  export NOMAD_TOKEN=$(consul kv get $KV_PATH/acl/bootstrap_token)
fi
