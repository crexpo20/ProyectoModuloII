/* Carga de la tabla de hechos FactSales en NorthwindDW */

USE [NorthwindDW];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    -- 1. Limpiar la tabla de hechos
    DELETE FROM dbo.FactSales;

    -- 2. CTE para calcular el importe neto por línea de pedido
    ;WITH Lineas AS (
        SELECT 
            o.OrderID, 
            o.CustomerID, 
            o.EmployeeID, 
            o.ShipVia,
            o.ShipCity,
            o.ShipCountry,
            CAST(o.OrderDate AS date) AS OrderDate,
            od.ProductID, 
            od.UnitPrice, 
            od.Quantity, 
            od.Discount,
            CAST(od.UnitPrice * od.Quantity * (1.0 - od.Discount) AS decimal(19,4)) AS ImporteNeto
        FROM Northwind.dbo.Orders AS o
        INNER JOIN Northwind.dbo.[OrderDetails] AS od ON od.OrderID = o.OrderID
    )

    -- 3. Inserción en dbo.FactSales (sin la columna Freight)
    INSERT INTO dbo.FactSales (
        OrderID,
        ProductID,
        OrderDateKey,
        CustomerKey,
        ProductKey,
        EmployeeKey,
        ShipperKey,
        ShipLocationKey,
        UnitPrice,
        Quantity,
        Discount,
        SalesAmount
    )
    SELECT 
        l.OrderID,
        l.ProductID,
        dt.DateKey,
        dc.CustomerKey,
        dp.ProductKey,
        de.EmployeeKey,
        ds.ShipperKey,
        COALESCE(dsl.ShipLocationKey, 1),
        l.UnitPrice,
        l.Quantity,
        l.Discount,
        CAST(l.ImporteNeto AS decimal(19,4))
    FROM Lineas AS l
    INNER JOIN dbo.DimDate AS dt ON dt.FullDate = l.OrderDate
    INNER JOIN dbo.DimCustomer AS dc ON dc.CustomerID = l.CustomerID
    INNER JOIN dbo.DimProduct AS dp ON dp.ProductID = l.ProductID
    INNER JOIN dbo.DimEmployee AS de ON de.EmployeeID = l.EmployeeID
    LEFT JOIN dbo.DimShipper AS ds ON ds.ShipperID = l.ShipVia
    LEFT JOIN dbo.DimShipLocation AS dsl 
           ON dsl.ShipCity = l.ShipCity 
          AND dsl.ShipCountry = l.ShipCountry;

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
GO

/* Verificación de registros cargados en FactSales */
SELECT 
    COUNT(*) AS FilasFactVentas, 
    SUM(SalesAmount) AS VentasNetas
FROM dbo.FactSales;
GO