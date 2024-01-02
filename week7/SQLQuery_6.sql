SELECT TOP 5 Customer_ID, SUM(Price * Quantity) AS ToplamGelir
FROM retail_2010_2011
GROUP BY Customer_ID

SELECT TOP 5 Customer_ID, SUM(Quantity * Price) AS ToplamGelir
FROM retail_2010_2011
GROUP BY Customer_ID

SELECT TOP 5 Customer_ID,
       DATEDIFF(DAY, MAX(InvoiceDate), '2011-12-30') AS Recency
FROM retail_2010_2011
GROUP BY Customer_ID