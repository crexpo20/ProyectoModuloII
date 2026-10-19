USE [NorthwindDW];
GO

/* 1. Conteo de dimensiones y tabla de hechos */
SELECT 'DimCustomer' AS Tabla, COUNT(*) AS Filas FROM dbo.DimCustomer
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM dbo.DimEmployee
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimDate', COUNT(*) FROM dbo.DimDate
UNION ALL SELECT 'DimShipper', COUNT(*) FROM dbo.DimShipper
UNION ALL SELECT 'FactSales', COUNT(*) FROM dbo.FactSales;
GO

/* 2. Muestra de registros de la tabla de hechos */
SELECT TOP (25) 
    OrderDateKey, 
    CustomerKey, 
    ProductKey,
    Quantity, 
    UnitPrice, 
    Discount, 
    SalesAmount
FROM dbo.FactSales
ORDER BY OrderID, ProductKey;
GO
