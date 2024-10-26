#!/usr/bin/env bash

set -euo pipefail

curl -Ls https://gist.github.com/gusztavvargadr/1f0d7dddc7f48549368eaaedf19bfe55/raw/provision.sh | sudo CHEF_POLICY="gusztavvargadr_development" bash -s

sudo apt remove -y consul

sudo apt install -y git jq net-tools consul=1.19.2-1
sudo apt autoremove -y
sudo apt clean -y

sudo apt-mark hold consul
