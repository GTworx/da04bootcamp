SELECT 
AVG(DATEDIFF(DAY,RequiredDate,ShippedDate)) AS OrtalamaGecikmeGun
FROM 
Orders
WHERE 
DATEDIFF(DAY,RequiredDate,ShippedDate) > 0

SELECT 
AVG(DATEDIFF(DAY,ShippedDate,RequiredDate)) AS OrtalamaGecikmeGun
FROM 
Orders
WHERE 
DATEDIFF(DAY,ShippedDate,RequiredDate) > 0