CREATE VIEW dbo.[Product Sales for 1997] AS
SELECT 
    c.CategoryName, 
    p.ProductName, 
    SUM(CONVERT(money, (od.UnitPrice * od.Quantity * (1 - od.Discount)))) AS ProductSales
FROM dbo.Categories c
JOIN dbo.Products p ON c.CategoryID = p.CategoryID
JOIN dbo.OrderDetails od ON p.ProductID = od.ProductID
JOIN dbo.Orders o ON o.OrderID = od.OrderID
WHERE o.OrderDate BETWEEN '19970101' AND '19971231'
GROUP BY c.CategoryName, p.ProductName;