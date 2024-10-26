#!/usr/bin/env bash

set -euo pipefail

DIR=$(dirname "$0")
pushd $DIR

bash $DIR/consul/apply.sh
bash $DIR/nomad/apply.sh

popd
