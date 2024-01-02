SELECT top 5
    StockCode,
    sum(Quantity) as ToplamSiparisAdet
FROM retail_2010_2011
GROUP BY StockCode
ORDER BY ToplamSiparisAdet DESC

SELECT top 5
    StockCode,
    Quantity,
    Country
FROM retail_2010_2011