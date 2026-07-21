SELECT
    sector_name,
    ROUND(STDDEV(daily_return)*SQRT(252)*100,2) AS volatility
FROM vw_sector_prices_enriched
GROUP BY sector_name
ORDER BY volatility DESC;

SELECT
    sector_name,
    ROUND(AVG(overnight_return)*100,2) AS avg_overnight,
    ROUND(AVG(intraday_return)*100,2) AS avg_intraday
FROM vw_sector_prices_enriched
GROUP BY sector_name;