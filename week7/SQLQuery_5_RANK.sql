WITH RankedStockCodes AS (
  SELECT
    StockCode,
    Country,
    SUM(Price * Quantity) AS PxQ,
    ROW_NUMBER() OVER (PARTITION BY Country ORDER BY SUM(Quantity) DESC) AS RowNum
  FROM
    retail_2010_2011
  GROUP BY
    StockCode,
    Country
)
SELECT
  StockCode,
  Country,
  PxQ
FROM
  RankedStockCodes
WHERE
  RowNum <= 5
ORDER BY
  Country,
  RowNum;
