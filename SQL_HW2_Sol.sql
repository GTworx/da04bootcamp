-- Soru: Tüm tablodaki CustomerID, Country, City kolonlarındaki verileri çekiniz

SELECT CustomerID, Country, City
FROM Customers

-- Soru: Ülkelerin ismini tekil olarak elde ediniz

SELECT DISTINCT Country
FROM Customers

-- Soru: Country içerisinden Brazil olanları çekiniz
SELECT *
FROM Customers
WHERE Country = 'Brazil'

--Soru: Country içerisinden 'Brazil' ve City= 'Sao Paulo' çekiniz

SELECT *
FROM Customers
WHERE Country = 'Brazil' 
AND City =  'Sao Paulo'

--Soru: Madridde yada San Francisco'da yaşayan müşterileri çekiniz

SELECT * 
FROM Customers
WHERE City in ('San Francisco','Madrid')

-- Soru: Stoktaki ürünlerin adetlerini çekiniz

SELECT ProductID, ProductName, SUM(UnitsInStock) as Stok_Adet
FROM Products
GROUP BY ProductID, ProductName

-- Soru: Her bir ürünlden kaç adet satılmış getiriniz.

SELECT ProductID, SUM(Quantity) satis_adeti
FROM [Order Details]
GROUP BY ProductID


-- Soru: Her bir üründen kaç adet satılmış getiriniz. Ürün ismi ile birlikte

SELECT o.ProductID, ProductName, SUM(Quantity) satis_adeti
FROM [Order Details] o
LEFT JOIN Products p
ON o.ProductID = p.ProductID
GROUP BY o.ProductID, ProductName



-- Soru: Ürün ve Şirket adlarını listeleyiniz ve adetlerini bulun 

SELECT s.CompanyName, COUNT(p.CategoryID) as urun_adeti
FROM Suppliers s
LEFT JOIN Products p
ON s.SupplierID = p.SupplierID
GROUP BY s.CompanyName



------XXXXX ASIL ODEV XXXXX-----
-- 1. "Geciken Urunler" ortalama kaç gün geciktiğini bulan sorguyu yazınız.

--subquery içeren
SELECT AVG(gecikme) Ortalama_gecikme
FROM 
(
    SELECT 
    OrderID, 
    DATEDIFF(DAY, RequiredDate, ShippedDate) as gecikme
    FROM Orders
    WHERE DATEDIFF(DAY, RequiredDate, ShippedDate ) > 0
) A

--subquery olmadan
SELECT AVG(DATEDIFF(DAY, RequiredDate, ShippedDate)) as gecikme
FROM Orders
WHERE DATEDIFF(DAY, RequiredDate, ShippedDate ) > 0


-- 2. "Erken Giden Urunler" in ortalama kaç gün erken gittiğini bulan sorguyu yazınız.

--subquery içeren
SELECT AVG(erken_gelis) ortalama_erken_teslim
FROM 
(
    SELECT 
    OrderID, 
    DATEDIFF(DAY, RequiredDate, ShippedDate) as erken_gelis
    FROM Orders
    WHERE DATEDIFF(DAY, RequiredDate, ShippedDate) < 0
) A


--subquery olmadan
SELECT AVG(DATEDIFF(DAY, RequiredDate, ShippedDate)) as ortalama_erken_teslim
FROM Orders
WHERE DATEDIFF(DAY, RequiredDate, ShippedDate ) < 0



-- 3. CustomerID bazında Toplam Ne Kadar Gelir elde edildiğini gösteren tabloyu getiren sorguyu yazınız. - Monetary

SELECT 
Customer_ID, 
SUM(Quantity*Price) as Monetary
FROM retail_2010_2011
GROUP BY Customer_ID

-- 4. CustomerID bazında 2011.12.30 tarihine göre Recency değerlerini gösteren tabloyu oluşturacak sorguyu yazınız.


SELECT Customer_ID, MAX(InvoiceDate) as Last_Purchase_Date, DATEDIFF(DAY, MAX(InvoiceDate), '20111230') as Recency
FROM retail_2010_2011
GROUP BY Customer_ID


SELECT Customer_ID, MIN(Sure) as Recency 
FROM (
    SELECT Customer_ID, DATEDIFF(DAY, InvoiceDate, '20111230') as Sure
    FROM retail_2010_2011
) t1
GROUP BY Customer_ID


-- 5. Ülke bazında en fazla satın alınan ürünlerin Toplam Cirosu nu gösteren tabloyu oluşturacak sorguyu yazınız.

SELECT *
FROM
(
    SELECT 
    Country, 
    [Description], 
    SUM(Quantity) as Adet, 
    SUM(Quantity*Price) as Total_Revenue,
    ROW_NUMBER() OVER(PARTITION BY Country,  ORDER BY SUM(Quantity) DESC) as Product_Rank
    FROM retail_2010_2011
    GROUP BY Country, [Description]
) A
WHERE Product_Rank = 1
ORDER BY Country



SELECT T2.* 
FROM
(
SELECT Country, MAX(Adet) as Max_Adet
FROM
(    SELECT Country, [Description], SUM(Quantity) as Adet, SUM(Quantity*Price) as Total_Revenue
    FROM retail_2010_2011
    GROUP BY Country, [Description]
    ) A 
GROUP BY Country ) T1
LEFT JOIN 
(
SELECT Country, [Description], SUM(Quantity) as Adet, SUM(Quantity*Price) as Total_Revenue
    FROM retail_2010_2011
    GROUP BY Country, [Description]
) T2
ON T1.Country = T2.Country
AND T1.Max_Adet = T2.Adet
ORDER BY T1.Country