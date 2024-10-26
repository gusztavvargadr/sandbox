#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$DIR/artifacts}"
mkdir -p $ARTIFACTS_DIR

docker compose up -d
sleep 5s

nohup nomad agent -dev -config=./nomad.hcl > $ARTIFACTS_DIR/nomad.log 2>&1 &
sleep 5s

source ./env.sh

nomad server members
nomad node status
nomad status

popd
