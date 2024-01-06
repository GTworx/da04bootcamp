-- a. Ilk 10 gözlem
SELECT TOP 10 * FROM retail_2010_2011

select * from onlineretaildb.INFORMATION_SCHEMA.COLUMNS

-- b. Değişken isimleri
SELECT COLUMN_NAME AS DEGISKEN_ISIMLERI
FROM onlineretaildb.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail_2010_2011';

--c. Boyut
SELECT COUNT(*) AS SATIR_SAYISI , 
       (SELECT COUNT(COLUMN_NAME) AS DEGISKEN_ISIMLERI
    FROM onlineretaildb.INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'retail_2010_2011') AS KOLON_SAYISI
FROM retail_2010_2011;

-- d. Boş değer
SELECT b.Item AS BasketItem, 
       s.Count AS StockCount
FROM basket b
LEFT JOIN stocks s ON b.Item = s.Item

SELECT A.COLUMN_NAME AS MYCOL
FROM onlineretaildb.INFORMATION_SCHEMA.COLUMNS AS A
WHERE A.TABLE_NAME = 'retail_2010_2011';

SELECT * FROM retail_2010_2011 WHERE Invoice IS NULL;

SELECT b.Item AS BasketItem, 
       a.Count AS StockCount
FROM basket b
LEFT JOIN stocks s ON b.Item = a.Item;
------------------------------------------------------------------------------
DECLARE @MyColumn NVARCHAR(MAX)
DECLARE @Check INT

-- Declare a cursor to iterate through the items in the basket
DECLARE mycolumn_cursor CURSOR FOR
SELECT A.COLUMN_NAME AS MYCOL
FROM onlineretaildb.INFORMATION_SCHEMA.COLUMNS AS A
WHERE A.TABLE_NAME = 'retail_2010_2011';

-- Open the cursor
OPEN mycolumn_cursor

-- Fetch the first item
FETCH NEXT FROM mycolumn_cursor INTO @MyColumn

-- Start the loop
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Initialize @StockCount to 0 for the current item
    --SET @StockCount = 0

    -- Check the count for the current item from the "stocks" table
    SELECT * FROM retail_2010_2011 WHERE @MyColumn IS NULL;
    --SELECT @StockCount = COUNT(*) 
    --FROM stocks 
    --WHERE Item = @MyColumn

    -- Display the result for the current item
    --PRINT 'Item: ' + @MyColumn + ', Stock Count: ' + CAST(@StockCount AS NVARCHAR(MAX))

    -- Fetch the next item
    FETCH NEXT FROM mycolumn_cursor INTO @MyColumn
END

-- Close and deallocate the cursor
CLOSE mycolumn_cursor
DEALLOCATE mycolumn_cursor
------------------------------------------------------------------------------
-- TENURE
SELECT
  Customer_ID,
  DATEDIFF(day, MIN(InvoiceDate), '2012-01-01') AS TenureInYears
FROM
  retail_2010_2011
GROUP BY
  Customer_ID

-- MONETARY
SELECT
  Customer_ID,
  SUM(Price * Quantity) AS MONETARY
FROM
  retail_2010_2011
WHERE
  InvoiceDate <= '2012-01-01'
GROUP BY
  Customer_ID

-- BASKET SIZE
SELECT
  Invoice,
  SUM(Price * Quantity) AS BasketSize
FROM
  retail_2010_2011
GROUP BY
  Invoice

-- FREQUENCY
SELECT
  Customer_ID,
  COUNT(DISTINCT Invoice) AS FREQUENCY
FROM
  retail_2010_2011
GROUP BY
  Customer_ID

-- RECENCY
SELECT
  Customer_ID,
  DATEDIFF(day, MAX(InvoiceDate), '2012-01-01') AS Recency
FROM
  retail_2010_2011
GROUP BY
  Customer_ID

/*
###############################################################
# GÖREV 2: RFM Metriklerinin Hesaplanması
###############################################################
*/

-- # Veri setindeki en son alışverişin yapıldığı tarihten 2 gün sonrasını analiz tarihi olarak alınacaktır.
-- 2021-05-30 max tarihtir.
SELECT MAX(InvoiceDate) AS MAX_SON_ALISVERIS_TARIHI FROM retail_2010_2011;
-- 2011-12-09 12:50:00.000

-- analysis_date = (2012,1,1)
-- customer_id, recency, frequnecy ve monetary değerlerinin yer aldığı yeni bir rfm adında tablo oluşturunuz.
SELECT CUSTOMER_ID,
     DATEDIFF(DAY, InvoiceDate, '20120101') AS RECENCY,
     order_num_total AS FREQUENCY,
     customer_value_total AS MONETARY,
     NULL RECENCY_SCORE,
     NULL FREQUENCY_SCORE,
     NULL MONETARY_SCORE
INTO playground.dbo.RFM_GTE
FROM retail_2010_2011
;

-- DROP TABLE playground.dbo.RFM_GTE

SELECT DISTINCT CUSTOMER_ID,
    NULL TENURE,
    NULL RECENCY,
    NULL FREQUENCY,
    NULL MONETARY,
    NULL RECENCY_SCORE,
    NULL FREQUENCY_SCORE,
    NULL MONETARY_SCORE
INTO playground.dbo.RFM_GTE
FROM retail_2010_2011
;

-- Recency, Frequency ve Monetary değerlerinin incelenmesi
select top 10 * from playground.dbo.RFM_GTE

-- TENURE
UPDATE playground.dbo.RFM_GTE SET TENURE = 
(SELECT TENURE FROM
(SELECT
  Customer_ID,
  DATEDIFF(day, MIN(InvoiceDate), '2012-01-01') AS TENURE
FROM
  retail_2010_2011
GROUP BY
  Customer_ID
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

select top 10 * from playground.dbo.RFM_GTE

-- RECENCY
UPDATE playground.dbo.RFM_GTE SET RECENCY = 
(SELECT RECENCY FROM
(SELECT
  Customer_ID,
  DATEDIFF(day, MAX(InvoiceDate), '2012-01-01') AS RECENCY
FROM
  retail_2010_2011
GROUP BY
  Customer_ID
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

select top 10 * from playground.dbo.RFM_GTE

-- FREQUENCY
UPDATE playground.dbo.RFM_GTE SET FREQUENCY = 
(SELECT FREQUENCY FROM
(SELECT
  Customer_ID,
  COUNT(DISTINCT Invoice) AS FREQUENCY
FROM
  retail_2010_2011
GROUP BY
  Customer_ID
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

select top 10 * from playground.dbo.RFM_GTE

-- MONETARY
UPDATE playground.dbo.RFM_GTE SET MONETARY = 
(SELECT MONETARY FROM
(SELECT
  Customer_ID,
  SUM(Price * Quantity) AS MONETARY
FROM
  retail_2010_2011
WHERE
  InvoiceDate <= '2012-01-01'
GROUP BY
  Customer_ID
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

select top 10 * from playground.dbo.RFM_GTE

/*
###############################################################
# GÖREV 3: RF ve RFM Skorlarının Hesaplanması (Calculating RF and RFM Scores)
###############################################################
#  Recency, Frequency ve Monetary metriklerinin 1-5 arasında skorlara çevrilmesi ve
# Bu skorları recency_score, frequency_score ve monetary_score olarak kaydedilmesi
*/

-- RECENCY_SCORE
UPDATE playground.dbo.RFM_GTE SET RECENCY_SCORE = 
(SELECT SCORE FROM
(SELECT A.*,
        NTILE(5) OVER(ORDER BY Recency DESC) SCORE
FROM playground.dbo.RFM_GTE AS A
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

SELECT TOP 10 * FROM playground.dbo.RFM_GTE

-- FREQUENCY_SCORE
UPDATE playground.dbo.RFM_GTE SET FREQUENCY_SCORE = 
(SELECT SCORE FROM
(SELECT A.*,
        NTILE(5) OVER(ORDER BY FREQUENCY) AS SCORE
FROM playground.dbo.RFM_GTE AS A
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

SELECT TOP 10 * FROM playground.dbo.RFM_GTE

-- MONETARY_SCORE
UPDATE playground.dbo.RFM_GTE SET MONETARY_SCORE = 
(SELECT SCORE FROM
(SELECT A.*,
        NTILE(5) OVER(ORDER BY MONETARY) AS SCORE
FROM playground.dbo.RFM_GTE AS A
) T 
WHERE T.Customer_ID = playground.dbo.RFM_GTE.Customer_ID
);

-- Oluşan skorların incelenmesi
SELECT TOP 10 * FROM playground.dbo.RFM_GTE;

-- # RECENCY_SCORE ve FREQUENCY_SCORE’u tek bir değişken olarak ifade edilmesi ve RF_SCORE olarak kaydedilmesi
ALTER TABLE playground.dbo.RFM_GTE ADD RF_SCORE AS (CONVERT(VARCHAR,RECENCY_SCORE) + CONVERT(VARCHAR,FREQUENCY_SCORE));

SELECT TOP 10 * FROM playground.dbo.RFM_GTE;

-- # RECENCY_SCORE ve FREQUENCY_SCORE ve MONETARY_SCORE'u tek bir değişken olarak ifade edilmesi ve RFM_SCORE olarak kaydedilmesi
ALTER TABLE playground.dbo.RFM_GTE ADD RFM_SCORE AS (CONVERT(VARCHAR,RECENCY_SCORE) + CONVERT(VARCHAR,FREQUENCY_SCORE) + CONVERT(VARCHAR, MONETARY_SCORE));


-- Son duruma göz atılması
SELECT TOP 10 * FROM playground.dbo.RFM_GTE;

/*
###############################################################
# GÖREV 4: RF Skorlarının Segment Olarak Tanımlanması
###############################################################
# Oluşturulan RFM skorların daha açıklanabilir olması için segment tanımlama ve RF_SCORE'u segmentlere çevirme
*/

--SEGMENT adında yeni bir kolon oluşturma
ALTER TABLE playground.dbo.RFM_GTE ADD SEGMENT VARCHAR(50);

-- Hibernating sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='hibernating'
WHERE RECENCY_SCORE LIKE '[1-2]%' AND FREQUENCY_SCORE LIKE '[1-2]%'

SELECT TOP 10 * FROM playground.dbo.RFM_GTE WHERE SEGMENT ='hibernating';

-- at Risk sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='at_Risk'
WHERE RECENCY_SCORE LIKE '[1-2]%' AND FREQUENCY_SCORE LIKE '[3-4]%'

-- Can't Loose sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='cant_loose'
WHERE RECENCY_SCORE LIKE '[1-2]%' AND FREQUENCY_SCORE LIKE '[5]%'

-- About to Sleep sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='about_to_sleep'
WHERE RECENCY_SCORE LIKE '[3]%' AND FREQUENCY_SCORE LIKE '[1-2]%'

-- Need Attention sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='need_attention'
WHERE RECENCY_SCORE LIKE '[3]%' AND FREQUENCY_SCORE LIKE '[3]%'

-- Loyal Customers sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='loyal_customers'
WHERE RECENCY_SCORE LIKE '[3-4]%' AND FREQUENCY_SCORE LIKE '[4-5]%'

-- Promising sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='promising'
WHERE RECENCY_SCORE LIKE '[4]%' AND FREQUENCY_SCORE LIKE '[1]%'

-- New Customers sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='new_customers'
WHERE RECENCY_SCORE LIKE '[5]%' AND FREQUENCY_SCORE LIKE '[1]%'

-- Potential Loyalist sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='potential_loyalists'
WHERE RECENCY_SCORE LIKE '[4-5]%' AND FREQUENCY_SCORE LIKE '[2-3]%'

-- Champions sınıfının oluşturulması
UPDATE playground.dbo.RFM_GTE SET SEGMENT ='champions'
WHERE RECENCY_SCORE LIKE '[5]%' AND FREQUENCY_SCORE LIKE '[4-5]%'

SELECT RFM_SCORE, SEGMENT FROM playground.dbo.RFM_GTE;

/*
###############################################################
# GÖREV 5: Aksiyon zamanı!
###############################################################
# 1. Segmentlerin recency, frequnecy ve monetary ortalamalarını inceleyiniz.
*/

SELECT SEGMENT,
       COUNT(RECENCY) AS COUNT_RECENCY,
     AVG(RECENCY) AS AVG_RECENCY,
     COUNT(FREQUENCY) AS COUNT_FREQUENCY,
     ROUND(AVG(FREQUENCY),3) AS AVG_FREQUENCY,
     COUNT(MONETARY) AS COUNT_MONETARY,
     ROUND(AVG(MONETARY),3) AS AVG_MONETARY
FROM playground.dbo.RFM_GTE
GROUP BY SEGMENT
;

/*
# 2. RFM analizi yardımı ile 2 case için ilgili profildeki müşterileri bulunuz.

# a. FLO bünyesine yeni bir kadın ayakkabı markası dahil ediyor. Dahil ettiği markanın ürün fiyatları genel müşteri tercihlerinin üstünde. Bu nedenle markanın
# tanıtımı ve ürün satışları için ilgilenecek profildeki müşterilerle özel olarak iletişime geçilmek isteniliyor. Bu müşterilerin sadık, ortalama 250 TL üzeri ve
# kadın kategorisinden alışveriş yapan kişiler olması planlandı. Müşterilerin id numaralarını getiriniz.

*/

(SELECT A.CUSTOMER_ID, B.interested_in_categories_12  
FROM playground.dbo.RFM_GTE AS A,
     flo AS B 
WHERE  A.CUSTOMER_ID = B.master_id
AND A.SEGMENT IN ('champions', 'loyal_customers')
AND (B.customer_value_total / B.order_num_total) > 250
AND B.interested_in_categories_12 LIKE '%KADIN%'
)
;


/*
# b. Erkek ve Çoçuk ürünlerinde %40'a yakın indirim planlanmaktadır. Bu indirimle ilgili kategorilerle ilgilenen geçmişte iyi müşterilerden olan ama uzun süredir
# alışveriş yapmayan ve yeni gelen müşteriler özel olarak hedef alınmak isteniliyor. Uygun profildeki müşterilerin id'lerini getiriniz.
*/

(SELECT A.CUSTOMER_ID, B.interested_in_categories_12  
FROM playground.dbo.RFM_GTE AS A,
     flo AS B 
WHERE  A.CUSTOMER_ID = B.master_id
AND A.SEGMENT IN ('cant_loose', 'hibernating', 'new_customers')
AND B.interested_in_categories_12 LIKE '%ERKEK%' OR B.interested_in_categories_12 LIKE '%COCUK%'
)
;