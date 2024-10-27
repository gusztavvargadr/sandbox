#!/usr/bin/env bash

set -euo pipefail

bash /var/tmp/cluster/bootstrap/apply.sh

aws s3 cp --recursive /var/tmp/cluster/artifacts s3://${bucket}
