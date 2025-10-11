-- Q1. List top 5 customers by total order amount.
-- Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

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
-- Q2. Find the number of products supplied by each supplier.
-- Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.


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


-- Q3. Identify products that have been ordered but never returned.
-- Show ProductID, ProductName, and total order quantity.

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


-- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

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


-- Q5. List all sales orders with customer name, product name, category, and supplier.
-- For each sales order, display:
-- OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

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

-- Q6. Find all shipments with details of warehouse, manager, and products shipped.
-- Display:
-- ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.
---Ans#6
SELECT 
    s.ShipmentID,
    -- w.Name as WarehouseName, # there is not find any data related to wharehouse name in the tables.
    e.Name as ManagerName,
    p.Name as ProductName,
    sd.Quantity as QuantityShipped,
    s.TrackingNumber
FROM dbo.Shipment s
JOIN dbo.Warehouse w ON s.WarehouseID = w.WarehouseID
JOIN dbo.Employee e ON w.ManagerID = e.EmployeeID
JOIN dbo.ShipmentDetail sd ON s.ShipmentID = sd.ShipmentID
JOIN dbo.Product p ON sd.ProductID = p.ProductID
ORDER BY s.ShipmentID;


-- Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

---Ans#7
WITH RankedOrders AS (
    SELECT 
        c.CustomerID,
        c.Name AS CustomerName,
      p.OrderID AS OrderID,
        so.TotalAmount,
        DENSE_RANK() OVER (
            PARTITION BY c.CustomerID 
            ORDER BY so.TotalAmount DESC
        ) AS OrderRank
    FROM dbo.Customer c
    JOIN dbo.SalesOrder so ON c.CustomerID = so.CustomerID
	join dbo.Payment p on so.OrderID=p.OrderID
)
SELECT 
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM RankedOrders
WHERE OrderRank <= 3
ORDER BY CustomerID, OrderRank;


-- Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.
---Answ#8
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    py. OrderID as orderid,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (
        PARTITION BY p.ProductID 
        ORDER BY so.OrderDate
    ) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (
        PARTITION BY p.ProductID 
        ORDER BY so.OrderDate
    ) AS NextQuantity
FROM dbo.Product p
JOIN dbo.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN dbo.SalesOrder so ON sod.OrderID = so.OrderID
JOIN DBO.Payment py on so.OrderID=py.orderid
ORDER BY p.ProductID, so.OrderDate;

-- Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
-- CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.
--- Ans#9
CREATE VIEW vw_CustomerOrderSummary AS
SELECT 
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(DISTINCT so.OrderID) AS TotalOrders,
    SUM(sod.Quantity * sod.UnitPrice) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM dbo.Customer c
LEFT JOIN dbo.SalesOrder so ON c.CustomerID = so.CustomerID
LEFT JOIN dbo.SalesOrderDetail sod ON so.OrderID = sod.OrderID
GROUP BY c.CustomerID, c.Name;

-- Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

--Ans#10

CREATE PROCEDURE sp_GetSupplierPurchases
    @SupplierID INT
AS
BEGIN
    SELECT 
        s.SupplierID,
        s.Name AS SupplierName,
        SUM(pod.Quantity * pod.UnitPrice) AS TotalPurchaseAmount
    FROM dbo.Supplier s
    JOIN dbo.PurchaseOrder po ON s.SupplierID = po.SupplierID
    JOIN dbo.PurchaseOrderDetail pod ON po.OrderID = pod.OrderID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID, s.Name;
END;



