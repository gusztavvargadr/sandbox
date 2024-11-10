#!/usr/bin/env bash

set -euo pipefail

consul members

source /var/tmp/cluster/core/env.sh

nomad server members
nomad node status
