#!/usr/bin/env bash

set -euo pipefail

curl -Ls https://github.com/gusztavvargadr.keys >> /home/ubuntu/.ssh/authorized_keys

# bash /var/tmp/cluster/core/initialize.sh

curl -Ls https://gist.github.com/gusztavvargadr/1f0d7dddc7f48549368eaaedf19bfe55/raw/provision.sh | sudo CHEF_POLICY="gusztavvargadr_development" bash -s
sudo usermod -aG docker ubuntu
sudo apt install -y git jq net-tools

CONSUL_VERSION=1.19.2
if [[ "$(consul --version)" != *"$CONSUL_VERSION"* ]]; then
  sudo apt-mark unhold consul
  sudo apt remove -y consul
  sudo apt install -y consul="$CONSUL_VERSION*"
  sudo apt-mark hold consul

  sudo sed -i "s/Type=notify/Type=simple/g" /lib/systemd/system/consul.service
  sudo systemctl daemon-reload
fi

NOMAD_VERSION=1.8.4
if [[ "$(nomad --version)" != *"$NOMAD_VERSION"* ]]; then
  sudo apt-mark unhold nomad
  sudo apt remove -y nomad
  sudo apt install -y nomad="$NOMAD_VERSION*"
  sudo apt-mark hold nomad

  sudo sed -i "s/Type=notify/Type=simple/g" /lib/systemd/system/nomad.service
  sudo systemctl daemon-reload
fi

if [ -z "$(aws --version)" ]; then
  sudo apt install -y  jq zip unzip
  pushd /tmp
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o -qq awscliv2.zip
  sudo ./aws/install
  popd
fi
