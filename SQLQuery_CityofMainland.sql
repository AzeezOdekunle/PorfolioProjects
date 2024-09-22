select * from Product
select * from ProductCategory
select * from Category
select * from PurchaseTrans

--				BUSINESS QUESTIONS

--	1. Produce a SQL Statement that joins all the tables to get the product name, product number and PurchaseTrans

SELECT p.ProductID,p.ProductName,p.ProductNumber,pt.AccountNumber,pt.Address,pt.CarrierTrackingNumber,pt.City,pt.Class, pt.Color,
pt.Country,pt.DueDate,pt.Employee,pt.ListPrice, pt.OrderDate,pt.OrderID,pt.OrderQty,pt.PostalCode,
pt.ShipDate,pt.SpecialOfferID, pt.StateProvince,pt.Supplier,pt.TransID,pt.UnitPrice,pt.UnitPriceDiscount FROM product p 
inner join PurchaseTrans pt on p.ProductID = pt.ProductID

--	2. Top 10 products ordered in each country on specific date with drill down summary of product detail including product category and net amount


Select * from 
(
select p.productname, p.ProductNumber, pt.ProductID, pt.orderdate, pt.Country, 
(pt. UnitPrice * pt.OrderQty) PurchaseAmount,
(pt. UnitPrice * pt.OrderQty)* pt. UnitPriceDiscount  as discountamount,
(pt. UnitPrice * pt.OrderQty) - (pt. UnitPrice * pt.OrderQty)* pt.UnitPriceDiscount as NetPurchaseAmount, DENSE_RANK () 
 over (order by pt.orderqty desc) as Top10 from PurchaseTrans pt
inner join product p ON pt.ProductID=p.ProductID
inner join ProductCategory pc ON p.ProductID=pc.ProductID
) a
where Top10 <= 10 
order by Top10 desc;




--	3. List of suppliers that offer discount amount on purchased products filtered by Product Category

select pt.supplier, Sum(pt.orderqty*pt.unitprice*pt.unitpriceDiscount) as DisountAmount, c.categoryName 
from PurchaseTrans pt inner join Product p on pt.ProductID = p.ProductID 
inner join ProductCategory pc on p.ProductID = pc.ProductID 
inner join Category c on pc.CategoryID = c.CategoryID 
Group by pt.supplier, c.categoryName, pt.orderqty, pt.unitprice, pt.unitpriceDiscount
Having (pt.orderqty*pt.unitprice*pt.unitpriceDiscount) <> 0
Order by c.CategoryName 

/*
	4.  Geographical display of total product purchased by class categories drill down by Country, State province and City with summary drill down 
	   of product information and purchased amount
*/

select p.productID, ProductNumber, p.productName, pt.class, pt.Country, pt.StateProvince,pt.City, sum(pt.UnitPrice*pt.OrderQty) as PurchasedAmount 
from PurchaseTrans pt 
inner join product p
on pt.ProductID = p.ProductID 
group by p.productID, p.ProductNumber, p.productName,pt.class, pt.Country, pt.StateProvince,pt.City
order by country desc


/*  
	5. Create KPI with Low, Medium, High indicator based on Net Purchase Amount with the following conditions:
      If the Net Purchase Amount is less than CAD 10,000 then “Low”
      If the Net Purchase Amount between CAD 10,000 and CAD 20,000 then “Medium”
      If the Net Purchase Amount greater than CAD 20,000 then “HIGH”
*/

select p.unitprice,(p.UnitPriceDiscount * 100) as 'Unit Price Discount %', p.OrderQty, (p.unitprice*p.orderQty) as PurchaseAmount, 
(p.unitprice*p.orderQty) - (p.UnitPriceDiscount * p.unitprice*p.orderQty) as NetPurchaseAmount,
case 
when (p.unitprice*p.orderQty) - (p.UnitPriceDiscount * p.unitprice*p.orderQty) <= 10000 then 'Low'
when (p.unitprice*p.orderQty) - (p.UnitPriceDiscount * p.unitprice*p.orderQty) >= 10000 
	and (p.unitprice*p.orderQty) - (p.UnitPriceDiscount * p.unitprice*p.orderQty)  <= 20000  then 'Medium'
when (p.unitprice*p.orderQty) - (p.UnitPriceDiscount * p.unitprice*p.orderQty)  >=20000 then 'High'
End as 'KPI Indicator'
from PurchaseTrans p
group by p.UnitPrice, p.OrderQty,p.UnitPriceDiscount