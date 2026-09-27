# Data provenance

Everything here is **synthetic**.

`data/sample/00_sample_data.sql` builds two populations on purpose:

- **a ring** — 3 buyers and 3 sellers, new accounts, 8 transactions per pair, every order at the 1-VND floor, value moving one way only
- **legitimate repeat customers** — older accounts, real prices, ordinary repeat behaviour

The test asserts the rule flags all 9 ring pairs and none of the legitimate ones. That second half matters more than the first: a rule that only catches fraud is easy, a rule that catches fraud *without* catching real customers is the job.

No marketplace data, campaign data or account records from any employer appear in this repository.
