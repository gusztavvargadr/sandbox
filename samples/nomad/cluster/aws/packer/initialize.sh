#!/usr/bin/env bash

set -euo pipefail

bash /var/tmp/cluster/core/initialize.sh

if [ -z "$(aws --version)" ]; then
  sudo apt install -y  jq zip unzip
  pushd /tmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o -qq awscliv2.zip
  sudo ./aws/install
  popd
fi
