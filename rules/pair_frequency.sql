-- Pair-level abuse detection. Every threshold is a parameter; nothing baked in.
WITH params AS (
    SELECT
        6      AS min_pair_txns,        -- repeat transactions between the same pair
        0.80   AS floor_threshold,      -- share of orders at the qualifying minimum
        0.95   AS one_sided_threshold,  -- value flowing one direction only
        14     AS new_account_window,   -- days between signup and first redemption
        1      AS floor_value           -- the campaign's minimum qualifying value
),

pairs AS (
    SELECT
        t.buyer_id,
        t.seller_id,
        COUNT(*)                                             AS pair_txn_count,
        SUM(CASE WHEN t.order_value <= (SELECT floor_value FROM params)
                 THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)      AS pct_orders_at_floor,
        SUM(t.order_value)                                   AS value_buyer_to_seller,
        MIN(t.order_date)                                    AS first_txn
    FROM campaign_transactions t
    WHERE t.voucher_applied = TRUE
    GROUP BY t.buyer_id, t.seller_id
),

flow AS (
    SELECT
        p.*,
        COALESCE(r.value_buyer_to_seller, 0)                 AS value_back,
        p.value_buyer_to_seller
          / NULLIF(p.value_buyer_to_seller
                   + COALESCE(r.value_buyer_to_seller, 0), 0) AS flow_ratio
    FROM pairs p
    LEFT JOIN pairs r
           ON r.buyer_id = p.seller_id
          AND r.seller_id = p.buyer_id
),

with_age AS (
    SELECT
        f.*,
        f.first_txn - a.created_at::date AS account_age_days
    FROM flow f
    JOIN accounts a ON a.account_id = f.buyer_id
)

SELECT
    buyer_id,
    seller_id,
    pair_txn_count,
    ROUND(pct_orders_at_floor, 2) AS pct_at_floor,
    ROUND(flow_ratio, 2)          AS flow_ratio,
    account_age_days,
    'REVIEW'                      AS action
FROM with_age, params
WHERE pair_txn_count      >= params.min_pair_txns
  AND pct_orders_at_floor >= params.floor_threshold
  AND flow_ratio          >= params.one_sided_threshold
  AND account_age_days    <= params.new_account_window
ORDER BY pair_txn_count DESC;

-- Note: this flags pairs for REVIEW, not for automatic penalty.
-- Any one signal on its own has a defensible innocent explanation.
