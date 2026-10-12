CREATE VIEW dbo.[Order Subtotals] AS
SELECT 
    od.OrderID, 
    SUM(CONVERT(money, (od.UnitPrice * od.Quantity * (1 - od.Discount)))) AS Subtotal
FROM dbo.OrderDetails od
GROUP BY od.OrderID;