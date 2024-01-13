SELECT TOP (1000) *
FROM [onlineretaildb].[dbo].[retail_2010_2011]

DROP TABLE RFM_CG;

CREATE TABLE RFM_CG (
    CustomerID varchar(20),
    LastInvoiceDate datetime,
    FirstInvoiceDate datetime,
    Recency int,
    Frequency int,
    Monetary int,
    Tenure int,
    Basket_Size float,
    Recency_Scale int,
    Frequency_Scale int,
    Monetary_Scale int,
    Tenure_Scale int,
    Segment varchar(100)
);

SELECT * FROM RFM_CG


-- Müşteri Id'lerin tekil olarak tabloya yazılması
INSERT INTO RFM_CG (CustomerID)
SELECT DISTINCT Customer_ID FROM OnlinE_RETail

SELECT * FROM RFM_CG

-- Müşterilerin son satın alma tarihlerinin çıkarılması

SELECT Customer_ID, MAX(InvoiceDate) AS SON_AV
FROM [onlineretaildb].[dbo].[retail_2010_2011]
GROUP BY Customer_ID

UPDATE RFM_CG SET LastInvoiceDate =
(
    SELECT MAX(InvoiceDate) 
    FROM [onlineretaildb].[dbo].[retail_2010_2011] o
    WHERE o.customer_ID = RFM_CG.CustomerID
)

SELECT * FROM RFM_CG

-- Recency
UPDATE RFM_CG SET Recency = DATEDIFF(DAY,LastInvoiceDate,'20120101')

SELECT * FROM RFM_CG

-- Frequency

UPDATE RFM_CG SET Frequency =
(
    SELECT COUNT(DISTINCT Invoice)
    FROM [onlineretaildb].[dbo].[retail_2010_2011] o
    WHERE o.customer_ID = RFM_CG.CustomerID
)

SELECT * FROM RFM_CG

--Monetary

UPDATE RFM_CG SET Monetary=
(SELECT sum(Price * quantity) 
FROM [onlineretaildb].[dbo].[retail_2010_2011] o 
WHERE o.customer_ID = RFM_CG.CustomerID)

SELECT * FROM RFM_CG

--Tenure

UPDATE RFM_CG SET FirstInvoiceDate =
(
    SELECT MIN(InvoiceDate) 
    FROM [onlineretaildb].[dbo].[retail_2010_2011] o
    WHERE o.customer_ID = RFM_CG.CustomerID
)

SELECT * FROM RFM_CG

UPDATE RFM_CG SET Tenure = DATEDIFF(DAY,FirstInvoiceDate,'20120101')

SELECT * FROM RFM_CG

--BasketSize
UPDATE RFM_CG SET Basket_Size=(Monetary / Frequency) FROM RFM_CG 

SELECT * FROM RFM_CG

/****
yukarıdaki adımları update işlemine ihtiyaç duymadan aşağıdaki şekilde de yapabilirdik.

SELECT Customer_ID,
DATEDIFF(day, MIN(InvoiceDate),'20120101') as Tenure,
DATEDIFF(day, MAX(InvoiceDate),'20120101') as Recency,
COUNT(DISTINCT Invoice) as Frequency, 
SUM(Quantity*Price) as Monetary, 
SUM(Quantity*Price) / COUNT(DISTINCT Invoice)  BasketSize,
Null recency_score,
Null Frequency_score,
Null Monetary_score 
INTO CG_RFM
from onlineretaildb.dbo.retail_2010_2011
group by Customer_ID


**/


---###### SCALE HESAPLARI #######-----

-- Recency scale hesaplanması

UPDATE RFM_CG SET Recency_Scale= 
( select RANK from
 (
    SELECT  *, NTILE(5) OVER( ORDER BY Recency desc) Rank
    FROM RFM_CG
) t
WHERE CustomerID = RFM_CG.CustomerID)

SELECT * FROM RFM_CG


-- Frequency scale hesaplanması
UPDATE RFM_CG SET Frequency_Scale= 
( select RANK from
 (
    SELECT  *, NTILE(5) OVER( ORDER BY Frequency) Rank
    FROM RFM_CG
) t
WHERE CustomerID = RFM_CG.CustomerID)

SELECT * FROM RFM_CG


-- Monetary scale hesaplanması
UPDATE RFM_CG SET Monetary_Scale= 
( select RANK from
 (
    SELECT  *, NTILE(5) OVER( ORDER BY Monetary) Rank
    FROM RFM_CG
) t
WHERE CustomerID = RFM_CG.CustomerID)

SELECT * FROM RFM_CG

-- Tenure scale hesaplanması
UPDATE RFM_CG SET Tenure_Scale= 
( select RANK from
 (
    SELECT  *, NTILE(5) OVER( ORDER BY Tenure) Rank
    FROM RFM_CG
) t
WHERE CustomerID = RFM_CG.CustomerID)

SELECT * FROM RFM_CG

---###### RFM SEGMENT İSİMLERİ MAPPING İŞLEMİ #######-----

UPDATE RFM_CG SET Segment = 'Need_Attention'
WHERE Recency_Scale LIKE '[3]' AND Frequency_Scale LIKE '[3]'
UPDATE RFM_CG SET Segment = 'Hibernating'
WHERE Recency_Scale LIKE '[1-2]' AND Frequency_Scale LIKE '[1-2]'
UPDATE RFM_CG SET Segment ='At_Risk' 
WHERE Recency_Scale LIKE  '[1-2]' AND Frequency_Scale LIKE '[3-4]'  
UPDATE RFM_CG SET Segment ='Cant_Loose' 
WHERE Recency_Scale LIKE  '[1-2]' AND Frequency_Scale LIKE '[5]'  
UPDATE RFM_CG SET Segment ='About_to_Sleep' 
WHERE Recency_Scale LIKE  '[3]' AND Frequency_Scale LIKE '[1-2]'  
UPDATE RFM_CG SET Segment ='Loyal_Customers' 
WHERE Recency_Scale LIKE  '[3-4]' AND Frequency_Scale LIKE '[4-5]' 
UPDATE RFM_CG SET Segment ='Promising' 
WHERE Recency_Scale LIKE  '[4]' AND Frequency_Scale LIKE '[1]' 
UPDATE RFM_CG SET Segment ='New_Customers' 
WHERE Recency_Scale LIKE  '[5]' AND Frequency_Scale LIKE '[1]' 
UPDATE RFM_CG SET Segment ='Potential_Loyalists' 
WHERE Recency_Scale LIKE  '[4-5]' AND Frequency_Scale LIKE '[2-3]' 
UPDATE RFM_CG SET Segment ='Champions' 
WHERE Recency_Scale LIKE  '[5]' AND Frequency_Scale LIKE '[4-5]'

SELECT Segment, COUNT(Segment)
FROM RFM_CG
WHERE CustomerID IS NOT NULL
GROUP BY Segment
ORDER BY COUNT(Segment) DESC