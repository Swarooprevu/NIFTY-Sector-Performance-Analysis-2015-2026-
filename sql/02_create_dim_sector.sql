USE nifty_sector_dw;
CREATE TABLE dim_sector (
    sector_id TINYINT PRIMARY KEY,
    sector_name VARCHAR(30) NOT NULL UNIQUE
);
INSERT INTO dim_sector (sector_id, sector_name)
VALUES
    (1, 'NIFTY 50'),
    (2, 'NIFTY AUTO'),
    (3, 'NIFTY BANK'),
    (4, 'NIFTY FMCG'),
    (5, 'NIFTY IT'),
    (6, 'NIFTY PHARMA');