CREATE VIEW dbo.[Order Details Extended] AS
SELECT 
    od.OrderID, 
    od.ProductID, 
    p.ProductName, 
    od.UnitPrice, 
    od.Quantity, 
    od.Discount,
    CONVERT(money, (od.UnitPrice * od.Quantity * (1 - od.Discount))) AS ExtendedPrice
FROM dbo.OrderDetails od
INNER JOIN dbo.Products p ON p.ProductID = od.ProductID;