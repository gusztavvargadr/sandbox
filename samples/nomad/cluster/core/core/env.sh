#!/usr/bin/env bash

KV_PATH=nomad

export NOMAD_ADDR="http://127.0.0.1:4646"
export NOMAD_TOKEN=$(consul kv get $KV_PATH/acl/bootstrap_token)
