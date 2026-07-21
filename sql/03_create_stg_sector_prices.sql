USE nifty_sector_dw;
CREATE TABLE stg_sector_prices (
    trade_date DATE NOT NULL,
    sector_name VARCHAR(30) NOT NULL,
    open_price DECIMAL(10,2) NOT NULL,
    high_price DECIMAL(10,2) NOT NULL,
    low_price DECIMAL(10,2) NOT NULL,
    close_price DECIMAL(10,2) NOT NULL,
    shares_traded BIGINT,
    turnover_cr DECIMAL(15,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NIFTY.csv'
INTO TABLE stg_sector_prices
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
trade_date,
sector_name,
open_price,
high_price,
low_price,
close_price,
@shares_traded,
@turnover_cr
)
SET
shares_traded = NULLIF(@shares_traded, ''),
turnover_cr = NULLIF(@turnover_cr, '')