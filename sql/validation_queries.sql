SELECT COUNT(*)
FROM stg_sector_prices;

SELECT MIN(trade_date), MAX(trade_date)
FROM stg_sector_prices;

SELECT sector_name, COUNT(*)
FROM stg_sector_prices
GROUP BY sector_name;

SELECT *
FROM stg_sector_prices
WHERE close_price IS NULL;

SELECT *
FROM stg_sector_prices
WHERE high_price < low_price;

SELECT DISTINCT s.sector_name
FROM stg_sector_prices s
LEFT JOIN dim_sector d
    ON s.sector_name = d.sector_name
WHERE d.sector_id IS NULL;

SELECT COUNT(*) FROM stg_sector_prices;

SELECT COUNT(*) FROM fact_sector_prices;

use nifty_sector_dw;
SELECT *
FROM vw_sector_prices_enriched
WHERE previous_close IS NULL;