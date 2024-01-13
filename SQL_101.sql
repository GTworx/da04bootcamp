-- 1.FLO tablosunu getirecek sorguyu yazınız.

SELECT * FROM FLO;

-- 2.Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.

SELECT 
COUNT(DISTINCT master_id) as Tekil_Musteri_Sayisi,
COUNT(master_id) as Musteri_Sayisi
FROM FLO;

-- 3.Toplam yapılan alışveriş adedini ve ciroyu getirecek sorguyu yazınız.


SELECT
SUM(order_num_total_ever_online + order_num_total_ever_offline) as toplam_alisveris_adedi, 
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) as toplam_ciro
FROM FLO;

-- 4.Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.

SELECT
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_online + order_num_total_ever_offline) AS aliveris_basina_ciro
FROM FLO;

--5.En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.

SELECT 
last_order_channel,
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS toplam_ciro,
SUM(order_num_total_ever_online + order_num_total_ever_offline) AS toplam_alisveris_adedi
FROM FLO
GROUP BY last_order_channel;

-- 6. YIL kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını baz alınız). Bu soruyu excel’de çözünüz ve görselleştiriniz.

SELECT 
YEAR(first_order_date) as yil,
SUM(order_num_total_ever_online + order_num_total_ever_offline) AS toplam_alisveris_adedi
FROM FLO
GROUP BY YEAR(first_order_date);

-- 7.En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.

SELECT last_order_channel,
--SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS toplam_ciro,
--SUM(order_num_total_ever_online + order_num_total_ever_offline) AS toplam_alisveris_adedi,
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_online + order_num_total_ever_offline)  AS sepet_buyuklugu
FROM FLO
GROUP BY last_order_channel;

-- 8.Online ve offline alışveriş yapan müşterilerin toplam cirolarını ayrı ayrı getiren sorguyu yazınız. Excel’de online ve offline platformda alışveriş yapan müşterilerin toplam harcamalarını bularak görselleştirin. �İpucu: SQL Başlıkları ”customer_value_total_ever_offline” , “customer_value_total_ever_online” 

SELECT 
master_id,
SUM(customer_value_total_ever_offline) AS offline_ciro,
SUM(customer_value_total_ever_online) AS  online_ciro
FROM FLO
GROUP BY master_id

-- 9.FLO tablosundaki master_id ve order_channel kolonlarını getiren sorguyu yazınız.

SELECT master_id, order_channel
FROM FLO;

-- 10.FLO tablosundan 'Offline' olmayan sipariş kanalına sahip kayıtları getiren sorguyu yazınız.

SELECT *
FROM FLO
WHERE last_order_channel != 'Offline'

-- 11.FLO tablosundan sipariş kanalı 'Offline' olmayan ve online alışverişlerinde ödediği toplam ücret 1000'den fazla olan kayıtları getiren  sorguyu yazınız. Ayrıca excel’de formül ile çözünüz.

SELECT master_id, order_channel, customer_value_total_ever_online
FROM FLO
WHERE last_order_channel != 'Offline' 
AND customer_value_total_ever_online > 1000

-- 12.FLO tablosundan alışveriş yapılan platforma ait sipariş kanalı ‘Mobile‘ olan, 
-- online ve offline alışveriş yapan müşterilerin toplam cirolarını getiren sorguyu yazınız.

SELECT 
SUM(customer_value_total_ever_offline) as offline_ciro,
SUM(customer_value_total_ever_online) as online_ciro
FROM FLO
where order_channel = 'Mobile'


-- 13.«interested_in_categories_12» kategorisi içerisinde “SPOR” geçen verileri getirecek sorguyu yazınız.

SELECT *
FROM FLO
WHERE interested_in_categories_12 LIKE 'SPOR%';


-- 14.Müşterinin offline alışverişlerinde ödediği ücretin 0 ile 10.000 arasında olduğu kayıtları getiren sorguyu yazınız.

SELECT *
FROM FLO
WHERE customer_value_total_ever_offline BETWEEN 0 AND 10000;

-- 15. interested_in_categories_12 ve order_channel bazında online sipariş adetlerini toplayan sorguyu yazınız ve excel’de görselleştiriniz.

SELECT interested_in_categories_12, order_channel, 
SUM(order_num_total_ever_online) as online_alisveris_adet
FROM FLO
GROUP BY interested_in_categories_12, order_channel
ORDER BY interested_in_categories_12, order_channel;

-- 16.En son alışveriş yapılan kanal (last_order_channel) bazında, 
-- her bir  kategoriden(interested_in_categories_12) kaç adet alışveriş yapıldığını getiren sorguyu yazınız 
-- ve adet sayısına göre büyükten küçüğe doğru sıralayanız.

SELECT 
last_order_channel, interested_in_categories_12, 
SUM(order_num_total_ever_offline+order_num_total_ever_online) as toplam_alisveris_adet
FROM FLO
GROUP BY last_order_channel, interested_in_categories_12
ORDER BY toplam_alisveris_adet DESC

-- 17.En çok alışveriş yapan 50 kişinin ID’ sini getiren sorguyu yazınız. Excel’de de en çok alışveriş yapan 50 müşterinin last_order_channel durumlarını inceleyerek görselleştiriniz.

SELECT TOP 50
master_id,
order_num_total_ever_offline+order_num_total_ever_online AS toplam_alisveris_adedi
FROM FLO
ORDER BY toplam_alisveris_adedi desc

-- 18.First Order Date e göre yıl bazında müşteri sayısını getiren sorguyu yazınız.

select
YEAR(first_order_date) as yil,
count(distinct master_id)
from flo
group by YEAR(first_order_date)
order by yil desc

-- 19.Last order date i 2020 olan müşterilerin sayısını getiren sorguyu yazınız.

SELECT
COUNT(DISTINCT master_id) AS muster_sayisi_2020
FROM FLO
WHERE YEAR(last_order_date) = 2020

-- 20.Sadece [AKTIFSPOR] dan alışveriş yapmış kişilerin Order Channel’larını sağ tarafa kolon olarak ekleyen sorguyu yazınız.

SELECT 
master_id,
interested_in_categories_12,
order_channel
FROM FLO
WHERE interested_in_categories_12 = '[AKTIFSPOR]'

-- 21. İçerisinde [AKTIFSPOR] dan alışveriş yapmış kişilerin Order Channel’larını sağ tarafa kolon olarak ekleyen sorguyu yazınız.

SELECT 
master_id,
interested_in_categories_12,
order_channel
FROM FLO
WHERE interested_in_categories_12 LIKE '%[AKTIFSPOR]%'


-- 22.2018/2019 arası her ay yeni gelen müşteri sayısını yıl ve ay kolonları ile birlikte getiren sorguyu yazınız.

SELECT YEAR(first_order_date) AS YIL, MONTH(first_order_date) AS AY, Count(DISTINCT master_id)
FROM FLO
WHERE YEAR(first_order_date) BETWEEN 2018 AND 2019
GROUP BY YEAR(first_order_date), MONTH(first_order_date)
ORDER BY YEAR(first_order_date), MONTH(first_order_date)

-- 23.Order_channel'da 'Mobile' veya 'Desktop' siparişlerinde interested_in_categories_12 de 'AKTIFSPOR' olmayan kayıtları getiren sorguyu yazınız.

SELECT *
FROM FLO
WHERE order_channel IN ('Mobile','Desktop')
AND interested_in_categories_12 NOT LIKE '%AKTIFSPOR%'

-- 24.Order_channel'da 'Mobile' veya 'Desktop' siparişlerin kayıtlarını getiren sorguyu yazınız.

SELECT *
FROM FLO
WHERE order_channel IN ('Mobile','Desktop')

 --25 Onlinedaki en çok siparişin olduğu(first_order_date) ay ı ve bu aydaki toplam siparişi(ciro) getiren sorguyu yazınız.

SELECT TOP 1 YEAR(first_order_date) as yil, MONTH(first_order_date) as month, SUM(customer_value_total_ever_online) AS online_siparis
FROM FLO
GROUP BY YEAR(first_order_date), MONTH(first_order_date)
ORDER BY online_siparis DESC

--Aşağıdaki soruları Northwind database içerisinde yapınız.

SELECT * FROM [Order Details]

SELECT * FROM Customers

SELECT * FROM Orders

SELECT * FROM Products

-- 26. Müşteriler ve onların verdiği siparişleri listeyecek sorguyu inner join ile yazınız.

SELECT * 
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID;

-- 27. Müşteriler ve onların verdiği siparişlerin detaylarını listeyecek sorguyu left join ile yazınız.

SELECT * 
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE OrderID is null

-- 28. Müşteriler ve onların verdiği siparişlerin detaylarını listeyecek sorguyu right join ile yazınız.

SELECT * 
FROM Customers c
RIGHT JOIN Orders o
ON c.CustomerID = o.CustomerID













