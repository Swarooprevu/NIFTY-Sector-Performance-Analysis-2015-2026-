USE nifty_sector_dw;
CREATE TABLE fact_sector_prices (
    price_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    trade_date DATE NOT NULL,
    sector_id TINYINT NOT NULL,
    open_price DECIMAL(10,2) NOT NULL,
    high_price DECIMAL(10,2) NOT NULL,
    low_price DECIMAL(10,2) NOT NULL,
    close_price DECIMAL(10,2) NOT NULL,
    shares_traded BIGINT,
    turnover_cr DECIMAL(15,2),

    CONSTRAINT fk_sector
        FOREIGN KEY (sector_id)
        REFERENCES dim_sector(sector_id),

    CONSTRAINT uq_trade_sector
        UNIQUE (trade_date, sector_id)
);

INSERT INTO fact_sector_prices
(
    trade_date,
    sector_id,
    open_price,
    high_price,
    low_price,
    close_price,
    shares_traded,
    turnover_cr
)
SELECT
    s.trade_date,
    d.sector_id,
    s.open_price,
    s.high_price,
    s.low_price,
    s.close_price,
    s.shares_traded,
    s.turnover_cr
FROM stg_sector_prices s
INNER JOIN dim_sector d
    ON s.sector_name = d.sector_name

WHERE NOT EXISTS
(
    SELECT 1
    FROM fact_sector_prices f
    WHERE f.trade_date = s.trade_date
      AND f.sector_id = d.sector_id
);