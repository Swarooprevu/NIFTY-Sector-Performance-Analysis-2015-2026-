USE nifty_sector_dw;
CREATE OR REPLACE VIEW vw_sector_prices_enriched AS
SELECT
    base_data.trade_date,
    base_data.trading_year,
    base_data.sector_id,
    base_data.sector_name,
    base_data.open_price,
    base_data.high_price,
    base_data.low_price,
    base_data.close_price,
    base_data.shares_traded,
    base_data.turnover_cr,
    base_data.previous_close,
    
    ROUND(
        (base_data.open_price - base_data.previous_close)
        / NULLIF(base_data.previous_close,0),
        4
    ) AS overnight_return,

    ROUND(
        (base_data.close_price - base_data.open_price)
        / NULLIF(base_data.open_price,0),
        4
    ) AS intraday_return,

    ROUND(
        (base_data.close_price - base_data.previous_close)
        / NULLIF(base_data.previous_close,0),
        4
    ) AS daily_return

FROM
(
    SELECT
        f.trade_date,
        YEAR(f.trade_date) AS trading_year,
        f.sector_id,
        d.sector_name,
        f.open_price,
        f.high_price,
        f.low_price,
        f.close_price,
        f.shares_traded,
        f.turnover_cr,
        LAG(f.close_price)
        OVER
        (
            PARTITION BY f.sector_id
            ORDER BY f.trade_date
        ) AS previous_close

    FROM fact_sector_prices f
    INNER JOIN dim_sector d
        ON f.sector_id = d.sector_id
) AS base_data