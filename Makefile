.PHONY: run test clean
PSQL ?= psql

run:            ## load synthetic transactions and run the rule
	$(PSQL) -v ON_ERROR_STOP=1 -q -f data/sample/00_sample_data.sql
	$(PSQL) -f rules/pair_frequency.sql

test:           ## assert the rule catches the ring and spares legitimate buyers
	bash tests/test_rules.sh

clean:
	$(PSQL) -c "DROP TABLE IF EXISTS campaign_transactions, accounts CASCADE;"
