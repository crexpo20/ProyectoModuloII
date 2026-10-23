-- Compara origen (NorthWind) contra destino (NorthWindDW). Devuelve una fila por validacion.
CREATE PROCEDURE [etl].[usp_Validate]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Validacion, Origen, Destino, CASE WHEN ABS(Origen - Destino) <= Tolerancia THEN 'OK' ELSE 'REVISAR' END AS Estado
    FROM (
        SELECT 'Clientes' AS Validacion, CAST((SELECT COUNT(*) FROM [NorthWind].[dbo].[Customers]) AS DECIMAL(19,4)) AS Origen,
               CAST((SELECT COUNT(*) FROM [dw].[DimCustomer] WHERE CustomerKey <> -1) AS DECIMAL(19,4)) AS Destino, CAST(0 AS DECIMAL(19,4)) AS Tolerancia
        UNION ALL SELECT 'Productos', (SELECT COUNT(*) FROM [NorthWind].[dbo].[Products]), (SELECT COUNT(*) FROM [dw].[DimProduct] WHERE ProductKey <> -1), 0
        UNION ALL SELECT 'Empleados', (SELECT COUNT(*) FROM [NorthWind].[dbo].[Employees]), (SELECT COUNT(*) FROM [dw].[DimEmployee] WHERE EmployeeKey <> -1), 0
        UNION ALL SELECT 'Transportistas', (SELECT COUNT(*) FROM [NorthWind].[dbo].[Shippers]), (SELECT COUNT(*) FROM [dw].[DimShipper] WHERE ShipperKey <> -1), 0
        UNION ALL SELECT 'Lineas de pedido (filas de hechos)', (SELECT COUNT(*) FROM [NorthWind].[dbo].[OrderDetails]), (SELECT COUNT(*) FROM [dw].[FactSales]), 0
        UNION ALL SELECT 'Venta neta total',
               (SELECT ISNULL(SUM(CAST(UnitPrice AS DECIMAL(19,4)) * Quantity * (1 - CAST(Discount AS DECIMAL(5,2)))), 0) FROM [NorthWind].[dbo].[OrderDetails]),
               (SELECT ISNULL(SUM(SalesAmount), 0) FROM [dw].[FactSales]), 0.01
        UNION ALL SELECT 'Flete total (pedidos con lineas)',
               (SELECT ISNULL(SUM(Freight), 0) FROM [NorthWind].[dbo].[Orders] o WHERE EXISTS (SELECT 1 FROM [NorthWind].[dbo].[OrderDetails] d WHERE d.OrderID = o.OrderID)),
               (SELECT ISNULL(SUM(FreightAllocated), 0) FROM [dw].[FactSales]), 1.00
        UNION ALL SELECT 'Hechos con cliente desconocido (debe ser 0)', 0, (SELECT COUNT(*) FROM [dw].[FactSales] WHERE CustomerKey = -1), 0
        UNION ALL SELECT 'Hechos con fecha de pedido desconocida (debe ser 0)', 0, (SELECT COUNT(*) FROM [dw].[FactSales] WHERE OrderDateKey = -1), 0
    ) v;
END
