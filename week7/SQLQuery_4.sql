select top 10 * from retail_2010_2011

select top 10 StockCode, Country, SUM(Price * Quantity) AS PxQ from retail_2010_2011

SELECT TOP 10 StockCode, Country, SUM(Price * Quantity) AS PxQ
FROM retail_2010_2011
GROUP BY StockCode, Country
ORDER BY PxQ DESC

SELECT DISTINCT Country from retail_2010_2011

SELECT TOP 10 StockCode, Country, PxQ FROM
(SELECT StockCode, Country, SUM(Price * Quantity) AS PxQ
FROM retail_2010_2011
GROUP BY StockCode, Country) AS PXQTABLE
ORDER BY Country, PxQ DESC

select top 5 Stockcode, Country FROM
(select StockCode, Country, SUM(Price * Quantity) AS PXQ from ORDER)
GROUP BY Country
ORDER BY PXQ