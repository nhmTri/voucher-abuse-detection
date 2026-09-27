#!/usr/bin/env bash
# Runs the detection rule against a throwaway Postgres and checks what it flags.
set -euo pipefail
PSQL="psql -v ON_ERROR_STOP=1 -q -X"

echo "→ loading synthetic transactions"
$PSQL -f data/sample/00_sample_data.sql

echo "→ running the rule"
FLAGGED=$($PSQL -t -A -F',' -f rules/pair_frequency.sql | sed '/^$/d' | sort)
COUNT=$(echo "$FLAGGED" | grep -c . || true)

echo "→ checking"
# the synthetic ring is 3 buyers x 3 sellers = 9 pairs, and no legitimate pair may be flagged
if [ "$COUNT" -ne 9 ]; then
  echo "✗ expected 9 flagged pairs, got $COUNT"; echo "$FLAGGED"; exit 1
fi
if echo "$FLAGGED" | grep -qE '^700[12],'; then
  echo "✗ a legitimate repeat buyer was flagged"; echo "$FLAGGED"; exit 1
fi
echo "✓ 9 ring pairs flagged, no legitimate buyer touched"
