--Answer#1
select top 5 c.customerid,c.Name as customer_name,o.totalamount
from dbo.Customer c
inner join 
dbo.salesorder o
on 
c.customerid=o.customerid
order by 
o.totalamount desc
;
---Answer#2
select   s.supplierid,s.name, count(d.ProductID) as product_Count
from dbo.supplier s
join
dbo.purchaseorder p
on
s.supplierid=p.supplierid
join
dbo.purchaseorderdetail d
on
p.orderid=d.orderid
group by  s.Name,
			s.SupplierID
			;

---Ans#3
SELECT 
    p.ProductID,
    p.Name,
    SUM(o.Quantity) as totalorderquantity
FROM dbo.product p
JOIN SalesOrderDetail o ON p.ProductID = o.ProductID
LEFT JOIN dbo.ReturnDetail d ON p.ProductID = d.ProductID
LEFT JOIN dbo.Returns R ON d.ReturnID = R.ReturnID
WHERE R.ReturnID IS NULL
GROUP BY p.ProductID, p.Name
HAVING SUM(o.Quantity) > 0;








