#!/usr/bin/env bash
cat <<'BANNER'

  Voucher abuse detection — this Codespace already has PostgreSQL 16 running
  with the synthetic sample loaded.

      make test     run the assertion: 9 ring pairs flagged, no legitimate buyer touched
      make run      load the sample again and print the result
      psql          poke at the tables yourself

  Nothing here is real data. Nothing leaves this container.

BANNER
