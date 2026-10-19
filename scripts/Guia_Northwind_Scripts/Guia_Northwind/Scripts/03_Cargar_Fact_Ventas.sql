/* Carga de la tabla de hechos FactSales en NorthWindDW */

USE [NorthWindDW];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Limpiar la tabla de hechos
    DELETE FROM dbo.FactSales;

    -- 2. Obtener las lineas de cada pedido
    ;WITH Lineas AS
    (
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
            CAST(
                od.UnitPrice * od.Quantity * (1.0 - od.Discount)
                AS decimal(19,4)
            ) AS ImporteNeto,
            CAST(o.Freight AS decimal(19,4)) AS Freight
        FROM Northwind.dbo.Orders AS o
        INNER JOIN Northwind.dbo.OrderDetails AS od
            ON od.OrderID = o.OrderID
    ),

    -- 3. Calcular el numero de linea y el total neto por pedido
    Distribucion AS
    (
        SELECT
            l.*,
            ROW_NUMBER() OVER (
                PARTITION BY l.OrderID
                ORDER BY l.ProductID
            ) AS NumeroLinea,
            COUNT(*) OVER (
                PARTITION BY l.OrderID
            ) AS TotalLineas,
            SUM(l.ImporteNeto) OVER (
                PARTITION BY l.OrderID
            ) AS TotalNetoPedido
        FROM Lineas AS l
    ),

    -- 4. Calcular el flete proporcional de cada linea,
    -- reservando la ultima linea para ajustar el redondeo
    AsignacionBase AS
    (
        SELECT
            d.*,
            CAST(
                CASE
                    WHEN d.TotalNetoPedido = 0
                         AND d.NumeroLinea = 1
                        THEN d.Freight

                    WHEN d.TotalNetoPedido = 0
                        THEN 0

                    WHEN d.NumeroLinea < d.TotalLineas
                        THEN ROUND(
                            d.Freight * d.ImporteNeto
                            / NULLIF(d.TotalNetoPedido, 0),
                            4
                        )

                    ELSE 0
                END
                AS decimal(19,4)
            ) AS FleteBase
        FROM Distribucion AS d
    ),

    -- 5. Ajustar la ultima linea para conservar
    -- exactamente el flete original del pedido
    FleteFinal AS
    (
        SELECT
            a.*,
            CAST(
                CASE
                    WHEN a.TotalNetoPedido = 0
                        THEN a.FleteBase

                    WHEN a.NumeroLinea = a.TotalLineas
                        THEN a.Freight
                             - SUM(
                                 CASE
                                     WHEN a.NumeroLinea < a.TotalLineas
                                         THEN a.FleteBase
                                     ELSE 0
                                 END
                               ) OVER (
                                   PARTITION BY a.OrderID
                               )

                    ELSE a.FleteBase
                END
                AS decimal(19,4)
            ) AS FreightAsignado
        FROM AsignacionBase AS a
    )

    -- 6. Insertar las ventas y el flete asignado
    INSERT INTO dbo.FactSales
    (
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
        SalesAmount,
        Freight
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
        l.ImporteNeto,
        l.FreightAsignado
    FROM FleteFinal AS l
    INNER JOIN dbo.DimDate AS dt
        ON dt.FullDate = l.OrderDate
    INNER JOIN dbo.DimCustomer AS dc
        ON dc.CustomerID = l.CustomerID
    INNER JOIN dbo.DimProduct AS dp
        ON dp.ProductID = l.ProductID
    INNER JOIN dbo.DimEmployee AS de
        ON de.EmployeeID = l.EmployeeID
    LEFT JOIN dbo.DimShipper AS ds
        ON ds.ShipperID = l.ShipVia
    LEFT JOIN dbo.DimShipLocation AS dsl
        ON dsl.ShipCity = l.ShipCity
       AND dsl.ShipCountry = l.ShipCountry;

    -- 7. Verificar los registros cargados
    SELECT
        COUNT(*) AS FilasFactVentas,
        SUM(SalesAmount) AS VentasNetas,
        SUM(Freight) AS FleteAsignadoTotal
    FROM dbo.FactSales;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
