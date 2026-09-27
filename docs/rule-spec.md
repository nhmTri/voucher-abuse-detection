# Rule specification — voucher abuse rings

Handed to a control team, not to a dashboard.

## Intent

Detect coordinated accounts created to harvest campaign vouchers, without flagging ordinary repeat customers.

## Signals and parameters

| Parameter | Meaning | Default | Set by |
|---|---|---|---|
| `min_pair_txns` | Repeat transactions between the same buyer and seller | 6 | campaign length |
| `floor_threshold` | Share of that pair's orders at the qualifying minimum | 0.80 | campaign terms |
| `one_sided_threshold` | Value flowing one direction only | 0.95 | category norms |
| `new_account_window` | Days between signup and first redemption | 14 | risk appetite |

All four must hold. Each one alone has an innocent explanation:

- a loyal customer buys from the same seller repeatedly
- some categories genuinely sell at the price floor
- most retail relationships are one-directional
- new users are not fraudulent by definition

## Output and escalation

The rule returns pairs with `action = 'REVIEW'`. It does **not** suspend accounts, reverse orders or withhold vouchers automatically. A human confirms before any penalty, because the cost of a false positive — a real customer accused of fraud — is higher than the cost of one missed ring in one campaign.

## Tuning

Loosen `min_pair_txns` for short campaigns; tighten `new_account_window` if the platform runs frequent sign-up promotions. Re-measure the flag rate after every change: a rule that fires on 5% of pairs is not a rule, it is noise.

## Known limits

- Rings that trade through a third account are invisible to pair-level logic; that needs graph traversal at depth 2+
- Value at the floor is campaign-specific and must be re-read per campaign
- Account age is weak where signup data is incomplete
