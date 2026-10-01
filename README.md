# Voucher Abuse Ring Detection

![Rule design](https://img.shields.io/badge/rule%20design-4%20signals-C0392B?style=flat-square)
![SQL](https://img.shields.io/badge/SQL-pair%20level-2456D6?style=flat-square&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-analysis-C2703A?style=flat-square&logo=powerbi&logoColor=white)
![Runnable](https://img.shields.io/badge/runs-out%20of%20the%20box-1F7A5A?style=flat-square)
[![rules](https://github.com/nhmTri/voucher-abuse-detection/actions/workflows/sql-tests.yml/badge.svg)](https://github.com/nhmTri/voucher-abuse-detection/actions/workflows/sql-tests.yml)
[![live demo](https://img.shields.io/badge/live%20demo-move%20the%20thresholds-184F95?style=flat-square&logo=githubpages&logoColor=white)](https://nhmtri.github.io/voucher-abuse-detection/)
[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-184F95?style=flat-square&logo=github&logoColor=white)](https://codespaces.new/nhmTri/voucher-abuse-detection?quickstart=1)
![Licence](https://img.shields.io/badge/licence-MIT-8892A6?style=flat-square)

<img src="assets/fraud-ring.svg" alt="A closed ring of three buyers and three sellers" width="100%">

> ### ▶ [Move the thresholds yourself](https://nhmtri.github.io/voucher-abuse-detection/)
>
> Nine abuse pairs are planted in the data, next to regulars, promo sign-ups, wholesale
> buyers and small resellers who all look suspicious in one way or another. Loosen a
> threshold and the page tells you what it cost you: **precision, recall, and exactly which
> ordinary customers you just swept in**. Nothing to install.

Pair-level network analysis on marketplace campaign transactions. Promotion budget was leaking, and totals looked normal — because **abuse hides in relationships, not in totals**.

**Found: a closed ring of 3 buyers and 3 sellers trading 1-VND orders**, created only to claim vouchers.

---

## Why totals missed it

Campaign-level spend, redemption rate and average order value all sat inside normal range. The ring only appears when you stop aggregating by campaign and start aggregating by **buyer–seller pair**: the same six accounts transacting with each other, at the price floor, in one direction, on accounts opened days before the campaign.

## The four signals

| Signal | What it measures | Why it matters alone is not enough |
|---|---|---|
| **Pair frequency** | Repeat transactions between the same buyer and seller | Loyal customers also repeat |
| **Value at the floor** | Order value at or near the minimum qualifying amount | Cheap products are also cheap |
| **One-sided flow** | Value moves one way and never back | Normal retail is one-sided too |
| **Account age at first redemption** | Days between account creation and first voucher claim | New users are not automatically fraudulent |

**No single signal is a rule.** Each one alone produces false positives on legitimate behaviour. The rule is the intersection — and the write-up argues the false-positive case explicitly, because a control team has to live with what it fires on.

## Output

Delivered as a rule specification a control team can run on live data, not as a one-off chart:

```
flag_pair  = pair_txn_count      >= :min_pair_txns
         AND pct_orders_at_floor >= :floor_threshold
         AND flow_ratio          >= :one_sided_threshold
         AND account_age_days    <= :new_account_window
```

Every threshold is a parameter. `rules/pair_frequency.sql` is the detection query; thresholds are set per campaign, not baked in.

## Run it in your browser, nothing installed

[![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-184F95?style=flat-square&logo=github&logoColor=white)](https://codespaces.new/nhmTri/voucher-abuse-detection?quickstart=1)

That button opens this repository in a container with **PostgreSQL 16 already running and the
sample already loaded** — the same shape as the CI job. When the terminal appears:

```bash
make test     # asserts 9 ring pairs flagged and no legitimate buyer touched
make run      # load the sample again and print the result
psql          # poke at the tables yourself
```

Re-runnable: the sample loader drops and rebuilds its tables, so `make test` gives the same
answer the fifth time as the first.

## Run it

```bash
make run     # load the synthetic ring plus legitimate repeat buyers, run the rule
make test    # assert it flags all 9 ring pairs and none of the legitimate ones
```

Or skip the install and [open the demo](https://nhmtri.github.io/voucher-abuse-detection/) — same rule, same planted ring, four sliders.

CI runs that assertion against PostgreSQL 16 on every push. **The test that matters is the second one** — a rule that catches fraud is easy, a rule that catches fraud without touching real customers is the job.

Full parameter table and escalation policy: [`docs/rule-spec.md`](docs/rule-spec.md). Data provenance: [`data/README.md`](data/README.md).

## Repo map

```
docs/index.html   the interactive demo, served by GitHub Pages
rules/            detection SQL
tests/            the assertion CI runs on every push
docs/rule-spec.md parameters, escalation policy and known limits
data/sample/      synthetic transactions - no client data
```

---

**Stack** · Power BI · Excel · transaction-level rule design · SQL
**More** · [portfolio case study](https://portfolionhmtri.netlify.app)
