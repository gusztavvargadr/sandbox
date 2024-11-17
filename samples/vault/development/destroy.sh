#!/usr/bin/env bash

nomad job stop vault-development

unset VAULT_ADDR
unset VAULT_TOKEN
