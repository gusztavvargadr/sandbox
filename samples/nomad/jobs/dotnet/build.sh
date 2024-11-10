#!/usr/bin/env bash

set -euo pipefail

docker buildx build --push --platform linux/amd64,linux/arm64 -t ghcr.io/gusztavvargadr/general-nomad-jobs-dotnet-api:latest -f ./src/api/Dockerfile .
