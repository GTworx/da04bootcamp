SELECT CompanyName, SUM(Freight) Toplam FROM
(SELECT S.ShipperID, S.CompanyName, O.Freight FROM
Shippers S LEFT JOIN Orders O
ON S.ShipperID = O.ShipVia) J
GROUP BY CompanyName

select top 10 StockCode, Country, sum(Price * Quantity) from ORDER

select top 5 Stockcode, Country FROM
(select StockCode, Country, SUM(Price * Quantity) AS PXQ from ORDER)
GROUP BY Country
ORDER BY PXQ

select top 5 StockCode, Country, sum(Quantity) from ORDER
GROUP BY StockCode, County
HAVING sum(Quantity)
