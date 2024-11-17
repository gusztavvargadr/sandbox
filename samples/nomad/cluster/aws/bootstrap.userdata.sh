#!/usr/bin/env bash

set -euo pipefail

curl -Ls https://github.com/gusztavvargadr.keys >> /home/ubuntu/.ssh/authorized_keys

bash /var/tmp/cluster/bootstrap/apply.sh

aws s3 cp --recursive /var/tmp/cluster/artifacts s3://${bucket}
