#!/usr/bin/env bash

terraform init
terraform apply -auto-approve

# SERVER_PUBLIC_IP=$(terraform output -json | jq -r .server.value.public_ip)
# BOOTSTRAP_TOKEN=$(terraform output -json | jq -r .bootstrap_token.value.SecretID)

# export NOMAD_ADDR="https://$SERVER_PUBLIC_IP:4646"
# export NOMAD_CAPATH="./config/artifacts/core/nomad-agent-ca.pem"
# export NOMAD_TLS_SERVER_NAME="127.0.0.1"
# export NOMAD_TOKEN="$BOOTSTRAP_TOKEN"
