#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/artifacts}"
mkdir -p $ARTIFACTS_DIR

nohup consul agent -dev -config-file=./consul.hcl > $ARTIFACTS_DIR/consul.log 2>&1 &
sleep 5s

consul members

popd
