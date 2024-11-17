#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR=${SOURCE_DIR:-$(dirname "$0")}
pushd $SOURCE_DIR

ARTIFACTS_DIR=${ARTIFACTS_DIR:-$SOURCE_DIR/artifacts}
mkdir -p $ARTIFACTS_DIR

if [ -z $(pgrep consul) ]; then
  nohup consul agent -dev -config-file=./consul.hcl > $ARTIFACTS_DIR/consul.log 2>&1 &
  sleep 2s
fi

consul members

if [ -z $(pgrep nomad) ]; then
  nohup nomad agent -dev -config=./nomad.hcl > $ARTIFACTS_DIR/nomad.log 2>&1 &
  sleep 5s
fi

nomad server members
nomad node status

popd
