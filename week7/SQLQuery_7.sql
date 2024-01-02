-- her kategori icin ortalama urun fiyatini bul
SELECT CategoryID, AVG(UnitPrice) AS AveragePrice
FROM Products
GROUP BY CategoryID;

SELECT C.CategoryName, AVG(P.UnitPrice) AS AveragePrice
FROM Products AS P
INNER JOIN Categories AS C ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryName;

-- stoktaki en yuksek urun miktari
SELECT MAX(UnitsInStock) AS MaxStockQuantity
FROM Products;

WITH T1 AS (
select ProductName, UnitsInStock, RANK() over(ORDER BY  UnitsInStock DESC) AS sıra from  Products )
SELECT ProductName, UnitsInStock FROM T1 WHERE sıra = 1;
-- tum urunlerin stoktaki miktari
select top 10 * from Products ORDER BY UnitsInStock ASC

-- musteriler ve verdikleri siparislerin detaylari
select C.CustomerID, O.* from Customers C left join Orders O on C.CustomerID=O.CustomerID 

SELECT o.CustomerID , 
COUNT(Distinct(OD.OrderID)) as Siparis_Sayısı ,
COUNT(Distinct(OD.ProductID)) as ürün_Sayısı ,
SUM(UnitPrice*Quantity) AS Toplam_Harcama,
Max(o.OrderDate) as Son_Sipariş_Tarihi
from Orders O
LEFT join [Order Details] OD ON OD.OrderID=O.OrderID
Group by o.CustomerID

SELECT
    YEAR(OrderDate) AS Yil,
    MONTH(OrderDate) AS Ay,
    SUM(Freight) AS ToplamSatis
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Yil, Ay;
-- 1. Yıllara ve Aylara Göre Toplam Satışları Bulacağınız Sorguyu Yazınız.
SELECT
    YEAR(Orders.OrderDate) AS Yil,
    MONTH(Orders.OrderDate) AS Ay,
    SUM(dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) AS ToplamSatis
FROM Orders
INNER JOIN dbo.[Order Details] ON Orders.OrderID = dbo.[Order Details].OrderID
GROUP BY YEAR(Orders.OrderDate), MONTH(Orders.OrderDate)
ORDER BY Yil, Ay;

-- 2. En Yüksek Sipariş Veren İlk 5 Müşteriyi Bulacağınız Sorguyu Yazınız.
SELECT TOP 5
    Customers.CustomerID,
    SUM(    .Quantity * dbo.[Order Details].UnitPrice) AS ToplamSiparisMiktari
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN dbo.[Order Details] ON Orders.OrderID = dbo.[Order Details].OrderID
GROUP BY Customers.CustomerID
ORDER BY ToplamSiparisMiktari DESC;

-- 3. Her Ürün İçin Ortalama Satış Fiyatını Bulacağınız Sorguyu Yazınız.
SELECT ProductID, AVG(UnitPrice) AS OrtalamaSatisFiyati
FROM dbo.[Order Details]
GROUP BY ProductID;

-- 4. Her Kategorideki Toplam Ürün Sayısını Bulacağınız Sorguyu Yazınız.
SELECT Categories.CategoryName, COUNT(Products.ProductID) AS ToplamUrunSayisi
FROM Categories
LEFT JOIN Products ON Categories.CategoryID = Products.CategoryID
GROUP BY Categories.CategoryName;

-- 5. Her Çalışanın Aldığı Toplam Sipariş Sayısını Bulacağınız Sorguyu Yazınız.
SELECT Employees.EmployeeID, Employees.FirstName, Employees.LastName, COUNT(Orders.OrderID) AS ToplamSiparisSayisi
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName;

-- 6. En Çok Sipariş Edilen Ürünleri Bulacağınız Sorguyu Yazınız.
SELECT TOP 5
    Products.ProductName,
    SUM(dbo.[Order Details].Quantity) AS ToplamSiparisMiktari
FROM dbo.[Order Details]
INNER JOIN Products ON dbo.[Order Details].ProductID = Products.ProductID
GROUP BY Products.ProductName
ORDER BY ToplamSiparisMiktari DESC;

-- 7. Her Müşteri İçin Toplam Harcama ve Ortalama Sipariş Değerini Bulacağınız Sorguyu Yazınız.
SELECT 
    Customers.CustomerID,
    SUM(dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) AS ToplamHarcama,
    AVG(dbo.[Order Details].UnitPrice * dbo.[Order Details].Quantity) AS OrtalamaSiparisDegeri
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
LEFT JOIN dbo.[Order Details] ON Orders.OrderID = dbo.[Order Details].OrderID
GROUP BY Customers.CustomerID;

-- 8. Her Ülkenin Müşteri Sayısını Bulacağınız Sorguyu Yazınız.
SELECT
    Country,
    COUNT(CustomerID) AS CustomerCount
FROM Customers
GROUP BY Country
ORDER BY CustomerCount DESC;

-- 9. Stoktaki Her Ürün İçin Toplam Değerini Bulacağınız Sorguyu Yazınız.
SELECT
    ProductName,
    SUM(UnitsInStock * UnitPrice) AS ToplamDeger
FROM Products
GROUP BY ProductName;

-- 10. Her Çalışanın Yönettiği Müşteri Sayısını Bulacağınız Sorguyu Yazınız.
SELECT
    Employees.EmployeeID,
    Employees.FirstName,
    Employees.LastName,
    COUNT(DISTINCT Customers.CustomerID) AS YonettigiMusteriSayisi
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
LEFT JOIN Customers ON Orders.CustomerID = Customers.CustomerID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName
ORDER BY YonettigiMusteriSayisi DESC;

SELECT
    Employees.EmployeeID,
    Employees.FirstName,
    Employees.LastName,
    COUNT(DISTINCT Orders.CustomerID) AS YonettigiMusteriSayisi
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName
ORDER BY YonettigiMusteriSayisi DESC;

SELECT
    Employees.EmployeeID,
    COUNT(DISTINCT Orders.CustomerID) AS YonettigiMusteriSayisi
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID;

-- 11. Her Kategorideki En Pahalı Ürünü Bulacağınız Sorguyu Yazınız.
WITH RankedProducts AS (
  SELECT
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice,
    ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS RowNum
  FROM Products
)

SELECT
  Categories.CategoryName,
  RankedProducts.ProductName,
  RankedProducts.UnitPrice AS EnPahaliFiyat
FROM Categories
INNER JOIN RankedProducts ON Categories.CategoryID = RankedProducts.CategoryID
WHERE RowNum = 1;

-- 12. Her Müşterinin İlk ve Son Sipariş Tarihlerini Bulacağınız Sorguyu Yazınız.
SELECT
    Customers.CustomerID,
    MIN(Orders.OrderDate) AS IlkSiparisTarihi,
    MAX(Orders.OrderDate) AS SonSiparisTarihi
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID;

SELECT
    CustomerID,
    MIN(OrderDate) AS IlkSiparisTarihi,
    MAX(OrderDate) AS SonSiparisTarihi
FROM Orders
GROUP BY CustomerID;

-- 13. Her Yıl İçin Toplam Satış Miktarını ve Ortalama Satış Değerini Bulacağınız Sorguyu Yazınız.
SELECT
    YEAR(OrderDate) AS Yil,
    SUM(Freight) AS ToplamSatisMiktari,
    AVG(Freight) AS OrtalamaSatisDegeri
FROM Orders
GROUP BY YEAR(OrderDate)
ORDER BY Yil;

-- 14. Her Ürün İçin Son Sipariş Tarihini Bulacağınız Sorguyu Yazınız.
SELECT
    Products.ProductName,
    MAX(Orders.OrderDate) AS SonSiparisTarihi
FROM Products
LEFT JOIN [Order Details] ON Products.ProductID = [Order Details].ProductID
LEFT JOIN Orders ON [Order Details].OrderID = Orders.OrderID
GROUP BY Products.ProductName;

-- 15. Her Müşteri İçin En Çok Satın Alınan Ürünü Bulacağınız Sorguyu Yazınız.
WITH CustomerMaxPurchase AS (
    SELECT
        Customers.CustomerID,
        Products.ProductName,
        SUM([Order Details].Quantity) AS ToplamSatisMiktari
    FROM Customers
    LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
    LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
    LEFT JOIN Products ON [Order Details].ProductID = Products.ProductID
    GROUP BY Customers.CustomerID, Products.ProductName
)

SELECT
    CustomerID,
    ProductName AS EnCokSatilanUrun
FROM (
    SELECT
        CustomerID,
        ProductName,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY ToplamSatisMiktari DESC) AS RowNum
    FROM CustomerMaxPurchase
) RankedProducts
WHERE RowNum = 1;

-- calisanlarin aldiklari siparis sayisina göre siralamasi
SELECT
    Employees.EmployeeID,
    Employees.FirstName,
    Employees.LastName,
    COUNT(Orders.OrderID) AS SiparisSayisi
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName
ORDER BY SiparisSayisi DESC;

-- ve her calisan icin performans durumunu belirt. 0-70 Low Performer, 70-119 Average Performer, 120 ve ustu: Top Performer
SELECT
    E.EmployeeID,
    E.FirstName,
    E.LastName,
    COUNT(Orders.OrderID) AS SiparisSayisi,
    CASE
        WHEN COUNT(Orders.OrderID) BETWEEN 0 AND 70 THEN 'Low Performer'
        WHEN COUNT(Orders.OrderID) BETWEEN 71 AND 119 THEN 'Average Performer'
        WHEN COUNT(Orders.OrderID) BETWEEN 120 AND 170 THEN 'Top Performer'
        ELSE 'Unknown'
    END AS PerformansStatus
FROM Employees E
LEFT JOIN Orders ON E.EmployeeID = Orders.EmployeeID
GROUP BY E.EmployeeID, E.FirstName, E.LastName
ORDER BY SiparisSayisi DESC;

SELECT
    Employees.EmployeeID,
    Employees.FirstName,
    Employees.LastName,
    COUNT(Orders.OrderID) AS SiparisSayisi,
    CASE
        WHEN COUNT(Orders.OrderID) <= 70 THEN 'Low Performer'
        WHEN COUNT(Orders.OrderID) BETWEEN 71 AND 119 THEN 'Average Performer'
        WHEN COUNT(Orders.OrderID) >= 120 THEN 'Top Performer'
        ELSE 'Unknown'
    END AS PerformansDurumu
FROM Employees
LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName
ORDER BY SiparisSayisi DESC;
