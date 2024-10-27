#!/usr/bin/env bash

set -euo pipefail

mkdir -p /var/tmp/cluster/artifacts
aws s3 cp --recursive s3://${bucket} /var/tmp/cluster/artifacts

bash /var/tmp/cluster/server/apply.sh

aws s3 cp --recursive /var/tmp/cluster/artifacts s3://${bucket}
