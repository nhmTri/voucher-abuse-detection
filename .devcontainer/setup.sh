#!/usr/bin/env bash
# Runs once when the Codespace is built: psql client, then the sample data.
set -euo pipefail

echo "installing the postgres client"
sudo apt-get update -qq
sudo apt-get install -y -qq --no-install-recommends postgresql-client >/dev/null

echo "waiting for postgres"
for i in $(seq 1 40); do
  if pg_isready -q; then break; fi
  sleep 1
done
pg_isready || { echo "postgres did not come up"; exit 1; }

echo "loading the synthetic sample"
psql -v ON_ERROR_STOP=1 -q -f data/sample/00_sample_data.sql

echo "ready"
