#!/usr/bin/env bash

consul-template -config ./templates.hcl -once

. ./artifacts/env.sh
