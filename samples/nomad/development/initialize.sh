#!/usr/bin/env bash

set -euo pipefail

curl -Ls https://gist.github.com/gusztavvargadr/1f0d7dddc7f48549368eaaedf19bfe55/raw/provision.sh | sudo CHEF_POLICY="gusztavvargadr_development" bash -s
sudo apt update -y
sudo apt install -y git jq net-tools

sudo sed -i "s/Type=notify/Type=simple/g" /lib/systemd/system/consul.service
sudo systemctl daemon-reload

sudo sed -i "s/Type=notify/Type=simple/g" /lib/systemd/system/nomad.service
sudo systemctl daemon-reload
