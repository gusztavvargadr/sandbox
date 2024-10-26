#!/usr/bin/env bash

sudo cloud-init status --wait

sudo aws s3 cp --recursive s3://${bucket}/client/config/ /etc/nomad.d
sudo chown -R nomad:nomad /etc/nomad.d
sudo chmod -R o-rw /etc/nomad.d
sudo chmod o+r /etc/nomad.d/tls/ca-cert.pem

sudo systemctl enable nomad.service
sudo systemctl start nomad.service
sleep 15s

export NOMAD_ADDR="https://127.0.0.1:4646"
export NOMAD_CAPATH="/etc/nomad.d/tls/ca-cert.pem"

aws s3 cp --recursive s3://${bucket}/core/acl/ .
export NOMAD_TOKEN=$(jq -r .SecretID bootstrap.json)

nomad server members
nomad node status
nomad status
