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

---Ans#4

SELECT 
    c.CategoryID,
    c.Name as category_name,
    p.Name as product_name,
    p.Price
FROM dbo.Category c
JOIN dbo.Product p ON c.CategoryID = p.CategoryID
WHERE p.Price = (
    SELECT MAX(Price)
    FROM dbo.Product p2
    WHERE p2.CategoryID = c.CategoryID
)
ORDER BY c.CategoryID, p.Price DESC;

---Ans#5
select c.Name as customer_name,so.OrderID,p.Name as product_name,ct.Name as category_name,pdo.Quantity,s.Name as supplier_name
from dbo.Customer c
join
dbo.SalesOrder so
on c.CustomerID=so.CustomerID
join
dbo.SalesOrderDetail sd
on
so.OrderID=sd.OrderID
join
dbo.Product p
on
sd.ProductID=p.ProductID
JOIN
dbo.Category ct
on
ct.CategoryID=p.CategoryID
join
dbo.PurchaseOrderDetail pdo
on
pdo.ProductID=p.ProductID
join
dbo.PurchaseOrder po
on
po.OrderID=	pdo.OrderID
join
dbo.Supplier s
on s.SupplierID=po.SupplierID;





