-- Minimal synthetic schema so rules/pair_frequency.sql runs out of the box. No real data.
CREATE TABLE IF NOT EXISTS accounts (
    account_id  BIGINT PRIMARY KEY,
    created_at  TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS campaign_transactions (
    txn_id          BIGSERIAL PRIMARY KEY,
    buyer_id        BIGINT  NOT NULL,
    seller_id       BIGINT  NOT NULL,
    order_date      DATE    NOT NULL,
    order_value     NUMERIC(12,2) NOT NULL,
    voucher_applied BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO accounts (account_id, created_at) VALUES
 (9001, TIMESTAMP '2026-05-02 09:00'), (9002, TIMESTAMP '2026-05-02 09:05'),
 (9003, TIMESTAMP '2026-05-03 10:00'), (7001, TIMESTAMP '2023-01-10 08:00'),
 (7002, TIMESTAMP '2022-07-19 08:00');

-- the ring: new accounts, floor-value orders, one direction, many times
INSERT INTO campaign_transactions (buyer_id, seller_id, order_date, order_value, voucher_applied)
SELECT b.id, s.id, DATE '2026-05-10' + (g % 5), 1, TRUE
FROM (VALUES (9001),(9002),(9003)) AS b(id),
     (VALUES (9101),(9102),(9103)) AS s(id),
     generate_series(1, 8) AS g;

-- normal repeat customers: real prices, both directions over time, old accounts
INSERT INTO campaign_transactions (buyer_id, seller_id, order_date, order_value, voucher_applied) VALUES
 (7001, 7501, DATE '2026-05-11', 320000, TRUE),
 (7001, 7501, DATE '2026-05-19', 410000, TRUE),
 (7002, 7502, DATE '2026-05-12', 260000, TRUE);
