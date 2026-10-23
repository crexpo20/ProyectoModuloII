-- Carga completa (truncate + insert) de FactSales. Granularidad: una fila por linea de pedido.
-- Debe ejecutarse DESPUES de cargar todas las dimensiones.
CREATE PROCEDURE [etl].[usp_Load_FactSales]
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE [dw].[FactSales];

    ;WITH src AS (
        SELECT o.OrderID, od.ProductID, o.CustomerID, o.EmployeeID, o.ShipVia,
               o.OrderDate, o.RequiredDate, o.ShippedDate, ISNULL(o.Freight, 0) AS Freight,
               ISNULL(o.ShipCity, N'N/D') AS ShipCity, ISNULL(o.ShipRegion, N'N/D') AS ShipRegion,
               ISNULL(o.ShipCountry, N'N/D') AS ShipCountry,
               CAST(od.UnitPrice AS DECIMAL(19,4)) AS UnitPrice, od.Quantity,
               CAST(od.Discount AS DECIMAL(5,2)) AS Discount
        FROM [NorthWind].[dbo].[OrderDetails] od
        JOIN [NorthWind].[dbo].[Orders] o ON o.OrderID = od.OrderID
    ), calc AS (
        SELECT *,
               UnitPrice * Quantity                                  AS GrossAmount,
               CAST(UnitPrice * Quantity * Discount AS DECIMAL(19,4)) AS DiscountAmount
        FROM src
    ), net AS (
        SELECT *, GrossAmount - DiscountAmount AS SalesAmount,
               SUM(GrossAmount - DiscountAmount) OVER (PARTITION BY OrderID) AS OrderSales
        FROM calc
    )
    INSERT [dw].[FactSales]
        (OrderID, ProductKey, CustomerKey, EmployeeKey, ShipperKey, ShipLocationKey,
         OrderDateKey, RequiredDateKey, ShippedDateKey,
         UnitPrice, Quantity, Discount, GrossAmount, DiscountAmount, SalesAmount, FreightAllocated, DaysToShip)
    SELECT n.OrderID,
           p.ProductKey,
           ISNULL(c.CustomerKey, -1),
           ISNULL(e.EmployeeKey, -1),
           ISNULL(s.ShipperKey, -1),
           ISNULL(l.ShipLocationKey, -1),
           ISNULL(CONVERT(INT, CONVERT(CHAR(8), n.OrderDate, 112)), -1),
           ISNULL(CONVERT(INT, CONVERT(CHAR(8), n.RequiredDate, 112)), -1),
           ISNULL(CONVERT(INT, CONVERT(CHAR(8), n.ShippedDate, 112)), -1),
           n.UnitPrice, n.Quantity, n.Discount, n.GrossAmount, n.DiscountAmount, n.SalesAmount,
           CASE WHEN n.OrderSales = 0 THEN 0
                ELSE CAST(n.Freight * n.SalesAmount / n.OrderSales AS DECIMAL(19,4)) END,
           DATEDIFF(DAY, n.OrderDate, n.ShippedDate)
    FROM net n
    JOIN      [dw].[DimProduct]      p ON p.ProductID  = n.ProductID
    LEFT JOIN [dw].[DimCustomer]     c ON c.CustomerID = n.CustomerID
    LEFT JOIN [dw].[DimEmployee]     e ON e.EmployeeID = n.EmployeeID
    LEFT JOIN [dw].[DimShipper]      s ON s.ShipperID  = n.ShipVia
    LEFT JOIN [dw].[DimShipLocation] l ON l.ShipCity = n.ShipCity AND l.ShipRegion = n.ShipRegion AND l.ShipCountry = n.ShipCountry;
END
