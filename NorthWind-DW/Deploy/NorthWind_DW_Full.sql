/* NorthWind DW (modelo estrella) - script completo de despliegue
   1) Ejecutar primero el script NorthWind_OLTP_Full.sql (y tener datos en NorthWind)
   2) Ejecutar este script en SSMS
   3) EXEC etl.usp_Load_All;   y luego   EXEC etl.usp_Validate; */
USE [master];
GO
IF DB_ID(N'NorthWindDW') IS NULL CREATE DATABASE [NorthWindDW];
GO
USE [NorthWindDW];
GO
-- Schemas/Schemas.sql
CREATE SCHEMA [dw];
GO
CREATE SCHEMA [etl];
GO
-- Tables/DimDate.sql
-- Dimension Fecha (rol multiple: pedido, requerida, envio). DateKey = yyyymmdd. -1 = no definida
CREATE TABLE [dw].[DimDate] (
    [DateKey]     INT          NOT NULL,
    [FullDate]    DATE         NOT NULL,
    [Year]        SMALLINT     NOT NULL,
    [Quarter]     TINYINT      NOT NULL,
    [QuarterName] NVARCHAR(10) NOT NULL,
    [Month]       TINYINT      NOT NULL,
    [MonthName]   NVARCHAR(20) NOT NULL,
    [YearMonth]   CHAR(7)      NOT NULL,
    [DayOfMonth]  TINYINT      NOT NULL,
    [DayOfWeek]   TINYINT      NOT NULL,
    [DayName]     NVARCHAR(20) NOT NULL,
    [WeekOfYear]  TINYINT      NOT NULL,
    [IsWeekend]   BIT          NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey])
);
GO
-- Tables/DimCustomer.sql
-- Dimension Cliente (SCD Tipo 1). Origen: Customers
CREATE TABLE [dw].[DimCustomer] (
    [CustomerKey]  INT IDENTITY(1,1) NOT NULL,
    [CustomerID]   NCHAR(5)     NOT NULL,   -- llave de negocio
    [CompanyName]  NVARCHAR(40) NOT NULL,
    [ContactName]  NVARCHAR(30) NULL,
    [ContactTitle] NVARCHAR(30) NULL,
    [City]         NVARCHAR(15) NULL,
    [Region]       NVARCHAR(15) NULL,
    [PostalCode]   NVARCHAR(10) NULL,
    [Country]      NVARCHAR(15) NULL,
    CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey]),
    CONSTRAINT [UQ_DimCustomer_CustomerID] UNIQUE ([CustomerID])
);
GO
-- Tables/DimProduct.sql
-- Dimension Producto desnormalizada: Products + Categories + Suppliers
CREATE TABLE [dw].[DimProduct] (
    [ProductKey]          INT IDENTITY(1,1) NOT NULL,
    [ProductID]           INT           NOT NULL,   -- llave de negocio
    [ProductName]         NVARCHAR(40)  NOT NULL,
    [QuantityPerUnit]     NVARCHAR(20)  NULL,
    [ListUnitPrice]       DECIMAL(19,4) NULL,
    [Discontinued]        BIT           NOT NULL,
    [CategoryID]          INT           NULL,
    [CategoryName]        NVARCHAR(15)  NOT NULL,
    [CategoryDescription] NVARCHAR(MAX) NULL,
    [SupplierID]          INT           NULL,
    [SupplierName]        NVARCHAR(40)  NOT NULL,
    [SupplierCity]        NVARCHAR(15)  NULL,
    [SupplierCountry]     NVARCHAR(15)  NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductKey]),
    CONSTRAINT [UQ_DimProduct_ProductID] UNIQUE ([ProductID])
);
GO
-- Tables/DimEmployee.sql
-- Dimension Empleado (vendedor). Incluye el nombre del jefe para evitar auto-join en BI
CREATE TABLE [dw].[DimEmployee] (
    [EmployeeKey]    INT IDENTITY(1,1) NOT NULL,
    [EmployeeID]     INT           NOT NULL,   -- llave de negocio
    [FullName]       NVARCHAR(40)  NOT NULL,
    [Title]          NVARCHAR(30)  NULL,
    [HireDate]       DATE          NULL,
    [City]           NVARCHAR(15)  NULL,
    [Country]        NVARCHAR(15)  NULL,
    [ReportsToName]  NVARCHAR(40)  NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED ([EmployeeKey]),
    CONSTRAINT [UQ_DimEmployee_EmployeeID] UNIQUE ([EmployeeID])
);
GO
-- Tables/DimShipper.sql
-- Dimension Transportista. Origen: Shippers
CREATE TABLE [dw].[DimShipper] (
    [ShipperKey]  INT IDENTITY(1,1) NOT NULL,
    [ShipperID]   INT          NOT NULL,   -- llave de negocio
    [CompanyName] NVARCHAR(40) NOT NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED ([ShipperKey]),
    CONSTRAINT [UQ_DimShipper_ShipperID] UNIQUE ([ShipperID])
);
GO
-- Tables/DimShipLocation.sql
-- Dimension Destino de envio (ciudad/region/pais donde se entrega el pedido). Origen: Orders.Ship*
CREATE TABLE [dw].[DimShipLocation] (
    [ShipLocationKey] INT IDENTITY(1,1) NOT NULL,
    [ShipCity]        NVARCHAR(15) NOT NULL,
    [ShipRegion]      NVARCHAR(15) NOT NULL,
    [ShipCountry]     NVARCHAR(15) NOT NULL,
    CONSTRAINT [PK_DimShipLocation] PRIMARY KEY CLUSTERED ([ShipLocationKey]),
    CONSTRAINT [UQ_DimShipLocation] UNIQUE ([ShipCity],[ShipRegion],[ShipCountry])
);
GO
-- Tables/FactSales.sql
-- Tabla de hechos de ventas.
-- GRANULARIDAD: una fila por linea de pedido (OrderID + ProductID).
CREATE TABLE [dw].[FactSales] (
    [OrderID]          INT           NOT NULL,   -- dimension degenerada
    [ProductKey]       INT           NOT NULL,
    [CustomerKey]      INT           NOT NULL,
    [EmployeeKey]      INT           NOT NULL,
    [ShipperKey]       INT           NOT NULL,
    [ShipLocationKey]  INT           NOT NULL,
    [OrderDateKey]     INT           NOT NULL,
    [RequiredDateKey]  INT           NOT NULL,
    [ShippedDateKey]   INT           NOT NULL,   -- -1 si aun no se envia
    -- Medidas
    [UnitPrice]        DECIMAL(19,4) NOT NULL,
    [Quantity]         SMALLINT      NOT NULL,
    [Discount]         DECIMAL(5,2)  NOT NULL,   -- 0.05 = 5%
    [GrossAmount]      DECIMAL(19,4) NOT NULL,   -- UnitPrice * Quantity
    [DiscountAmount]   DECIMAL(19,4) NOT NULL,   -- GrossAmount * Discount
    [SalesAmount]      DECIMAL(19,4) NOT NULL,   -- GrossAmount - DiscountAmount (venta neta)
    [FreightAllocated] DECIMAL(19,4) NOT NULL,   -- Freight del pedido prorrateado por venta neta
    [DaysToShip]       INT           NULL,       -- dias entre pedido y envio (NULL si no enviado)
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([OrderID],[ProductKey]),
    CONSTRAINT [FK_FactSales_DimProduct]      FOREIGN KEY ([ProductKey])      REFERENCES [dw].[DimProduct]([ProductKey]),
    CONSTRAINT [FK_FactSales_DimCustomer]     FOREIGN KEY ([CustomerKey])     REFERENCES [dw].[DimCustomer]([CustomerKey]),
    CONSTRAINT [FK_FactSales_DimEmployee]     FOREIGN KEY ([EmployeeKey])     REFERENCES [dw].[DimEmployee]([EmployeeKey]),
    CONSTRAINT [FK_FactSales_DimShipper]      FOREIGN KEY ([ShipperKey])      REFERENCES [dw].[DimShipper]([ShipperKey]),
    CONSTRAINT [FK_FactSales_DimShipLocation] FOREIGN KEY ([ShipLocationKey]) REFERENCES [dw].[DimShipLocation]([ShipLocationKey]),
    CONSTRAINT [FK_FactSales_OrderDate]       FOREIGN KEY ([OrderDateKey])    REFERENCES [dw].[DimDate]([DateKey]),
    CONSTRAINT [FK_FactSales_RequiredDate]    FOREIGN KEY ([RequiredDateKey]) REFERENCES [dw].[DimDate]([DateKey]),
    CONSTRAINT [FK_FactSales_ShippedDate]     FOREIGN KEY ([ShippedDateKey])  REFERENCES [dw].[DimDate]([DateKey])
);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey] ON [dw].[FactSales]([OrderDateKey]);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerKey]  ON [dw].[FactSales]([CustomerKey]);
GO
-- StoredProcedures/etl_usp_Seed_UnknownMembers.sql
-- Crea el miembro "Desconocido" (clave -1) en cada dimension para no perder filas cuando
-- el origen trae NULL en una llave (p. ej. pedido sin cliente o aun no enviado).
CREATE PROCEDURE [etl].[usp_Seed_UnknownMembers]
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimDate] WHERE DateKey = -1)
        INSERT [dw].[DimDate] (DateKey, FullDate, [Year], [Quarter], QuarterName, [Month], [MonthName], YearMonth,
                               [DayOfMonth], [DayOfWeek], [DayName], WeekOfYear, IsWeekend)
        VALUES (-1, '19000101', 1900, 1, N'N/D', 1, N'N/D', '1900-01', 1, 1, N'N/D', 1, 0);

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimCustomer] WHERE CustomerKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimCustomer] ON;
        INSERT [dw].[DimCustomer] (CustomerKey, CustomerID, CompanyName) VALUES (-1, N'-1', N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimCustomer] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimProduct] WHERE ProductKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimProduct] ON;
        INSERT [dw].[DimProduct] (ProductKey, ProductID, ProductName, Discontinued, CategoryName, SupplierName)
        VALUES (-1, -1, N'Desconocido', 0, N'Sin categoria', N'Sin proveedor');
        SET IDENTITY_INSERT [dw].[DimProduct] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimEmployee] WHERE EmployeeKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimEmployee] ON;
        INSERT [dw].[DimEmployee] (EmployeeKey, EmployeeID, FullName) VALUES (-1, -1, N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimEmployee] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimShipper] WHERE ShipperKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimShipper] ON;
        INSERT [dw].[DimShipper] (ShipperKey, ShipperID, CompanyName) VALUES (-1, -1, N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimShipper] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimShipLocation] WHERE ShipLocationKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimShipLocation] ON;
        INSERT [dw].[DimShipLocation] (ShipLocationKey, ShipCity, ShipRegion, ShipCountry) VALUES (-1, N'N/D', N'N/D', N'N/D');
        SET IDENTITY_INSERT [dw].[DimShipLocation] OFF;
    END
END
GO
-- StoredProcedures/etl_usp_Load_DimDate.sql
-- Genera la dimension fecha cubriendo los anios completos presentes en Orders (pedido/requerida/envio)
CREATE PROCEDURE [etl].[usp_Load_DimDate]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @min DATE, @max DATE;

    SELECT @min = MIN(d), @max = MAX(d)
    FROM (SELECT CAST(OrderDate AS DATE) d FROM [NorthWind].[dbo].[Orders]
          UNION ALL SELECT CAST(RequiredDate AS DATE) FROM [NorthWind].[dbo].[Orders]
          UNION ALL SELECT CAST(ShippedDate AS DATE)  FROM [NorthWind].[dbo].[Orders]) x
    WHERE d IS NOT NULL;

    IF @min IS NULL RETURN;  -- origen sin pedidos

    SET @min = DATEFROMPARTS(YEAR(@min), 1, 1);
    SET @max = DATEFROMPARTS(YEAR(@max), 12, 31);

    ;WITH dates AS (
        SELECT @min AS d
        UNION ALL
        SELECT DATEADD(DAY, 1, d) FROM dates WHERE d < @max
    )
    INSERT [dw].[DimDate] (DateKey, FullDate, [Year], [Quarter], QuarterName, [Month], [MonthName], YearMonth,
                           [DayOfMonth], [DayOfWeek], [DayName], WeekOfYear, IsWeekend)
    SELECT CONVERT(INT, CONVERT(CHAR(8), d, 112)),
           d,
           YEAR(d),
           DATEPART(QUARTER, d),
           N'T' + CAST(DATEPART(QUARTER, d) AS NVARCHAR(1)),
           MONTH(d),
           CHOOSE(MONTH(d), N'Enero',N'Febrero',N'Marzo',N'Abril',N'Mayo',N'Junio',N'Julio',N'Agosto',N'Septiembre',N'Octubre',N'Noviembre',N'Diciembre'),
           CONVERT(CHAR(7), d, 126),
           DAY(d),
           (DATEDIFF(DAY, '19000101', d) % 7) + 1,     -- 1 = lunes ... 7 = domingo
           CHOOSE((DATEDIFF(DAY, '19000101', d) % 7) + 1, N'Lunes',N'Martes',N'Miercoles',N'Jueves',N'Viernes',N'Sabado',N'Domingo'),
           DATEPART(ISO_WEEK, d),
           CASE WHEN (DATEDIFF(DAY, '19000101', d) % 7) + 1 >= 6 THEN 1 ELSE 0 END
    FROM dates
    WHERE CONVERT(INT, CONVERT(CHAR(8), d, 112)) NOT IN (SELECT DateKey FROM [dw].[DimDate])
    OPTION (MAXRECURSION 0);
END
GO
-- StoredProcedures/etl_usp_Load_DimCustomer.sql
CREATE PROCEDURE [etl].[usp_Load_DimCustomer]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimCustomer] AS t
    USING (SELECT CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country
           FROM [NorthWind].[dbo].[Customers]) AS s
       ON t.CustomerID = s.CustomerID
    WHEN MATCHED THEN UPDATE SET
         CompanyName = s.CompanyName, ContactName = s.ContactName, ContactTitle = s.ContactTitle,
         City = s.City, Region = s.Region, PostalCode = s.PostalCode, Country = s.Country
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country)
         VALUES (s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle, s.City, s.Region, s.PostalCode, s.Country);
END
GO
-- StoredProcedures/etl_usp_Load_DimProduct.sql
-- Desnormaliza Products + Categories + Suppliers en una sola dimension
CREATE PROCEDURE [etl].[usp_Load_DimProduct]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimProduct] AS t
    USING (SELECT p.ProductID, p.ProductName, p.QuantityPerUnit,
                  CAST(p.UnitPrice AS DECIMAL(19,4)) AS ListUnitPrice, p.Discontinued,
                  p.CategoryID, ISNULL(c.CategoryName, N'Sin categoria') AS CategoryName, c.[Description] AS CategoryDescription,
                  p.SupplierID, ISNULL(s.CompanyName, N'Sin proveedor') AS SupplierName, s.City AS SupplierCity, s.Country AS SupplierCountry
           FROM [NorthWind].[dbo].[Products] p
           LEFT JOIN [NorthWind].[dbo].[Categories] c ON c.CategoryID = p.CategoryID
           LEFT JOIN [NorthWind].[dbo].[Suppliers]  s ON s.SupplierID = p.SupplierID) AS src
       ON t.ProductID = src.ProductID
    WHEN MATCHED THEN UPDATE SET
         ProductName = src.ProductName, QuantityPerUnit = src.QuantityPerUnit, ListUnitPrice = src.ListUnitPrice,
         Discontinued = src.Discontinued, CategoryID = src.CategoryID, CategoryName = src.CategoryName,
         CategoryDescription = src.CategoryDescription, SupplierID = src.SupplierID, SupplierName = src.SupplierName,
         SupplierCity = src.SupplierCity, SupplierCountry = src.SupplierCountry
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (ProductID, ProductName, QuantityPerUnit, ListUnitPrice, Discontinued, CategoryID, CategoryName,
                 CategoryDescription, SupplierID, SupplierName, SupplierCity, SupplierCountry)
         VALUES (src.ProductID, src.ProductName, src.QuantityPerUnit, src.ListUnitPrice, src.Discontinued, src.CategoryID,
                 src.CategoryName, src.CategoryDescription, src.SupplierID, src.SupplierName, src.SupplierCity, src.SupplierCountry);
END
GO
-- StoredProcedures/etl_usp_Load_DimEmployee.sql
CREATE PROCEDURE [etl].[usp_Load_DimEmployee]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimEmployee] AS t
    USING (SELECT e.EmployeeID, e.FirstName + N' ' + e.LastName AS FullName, e.Title,
                  CAST(e.HireDate AS DATE) AS HireDate, e.City, e.Country,
                  b.FirstName + N' ' + b.LastName AS ReportsToName
           FROM [NorthWind].[dbo].[Employees] e
           LEFT JOIN [NorthWind].[dbo].[Employees] b ON b.EmployeeID = e.ReportsTo) AS s
       ON t.EmployeeID = s.EmployeeID
    WHEN MATCHED THEN UPDATE SET
         FullName = s.FullName, Title = s.Title, HireDate = s.HireDate, City = s.City,
         Country = s.Country, ReportsToName = s.ReportsToName
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (EmployeeID, FullName, Title, HireDate, City, Country, ReportsToName)
         VALUES (s.EmployeeID, s.FullName, s.Title, s.HireDate, s.City, s.Country, s.ReportsToName);
END
GO
-- StoredProcedures/etl_usp_Load_DimShipper.sql
CREATE PROCEDURE [etl].[usp_Load_DimShipper]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimShipper] AS t
    USING (SELECT ShipperID, CompanyName FROM [NorthWind].[dbo].[Shippers]) AS s
       ON t.ShipperID = s.ShipperID
    WHEN MATCHED THEN UPDATE SET CompanyName = s.CompanyName
    WHEN NOT MATCHED BY TARGET THEN INSERT (ShipperID, CompanyName) VALUES (s.ShipperID, s.CompanyName);
END
GO
-- StoredProcedures/etl_usp_Load_DimShipLocation.sql
-- Combinaciones distintas de ciudad/region/pais de envio presentes en Orders
CREATE PROCEDURE [etl].[usp_Load_DimShipLocation]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT [dw].[DimShipLocation] (ShipCity, ShipRegion, ShipCountry)
    SELECT DISTINCT ISNULL(o.ShipCity, N'N/D'), ISNULL(o.ShipRegion, N'N/D'), ISNULL(o.ShipCountry, N'N/D')
    FROM [NorthWind].[dbo].[Orders] o
    WHERE NOT EXISTS (SELECT 1 FROM [dw].[DimShipLocation] d
                      WHERE d.ShipCity    = ISNULL(o.ShipCity, N'N/D')
                        AND d.ShipRegion  = ISNULL(o.ShipRegion, N'N/D')
                        AND d.ShipCountry = ISNULL(o.ShipCountry, N'N/D'));
END
GO
-- StoredProcedures/etl_usp_Load_FactSales.sql
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
GO
-- StoredProcedures/etl_usp_Load_All.sql
-- Orquestador del ETL: orden correcto (dimensiones primero, hechos al final) dentro de una transaccion
CREATE PROCEDURE [etl].[usp_Load_All]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            EXEC [etl].[usp_Seed_UnknownMembers];
            EXEC [etl].[usp_Load_DimDate];
            EXEC [etl].[usp_Load_DimCustomer];
            EXEC [etl].[usp_Load_DimProduct];
            EXEC [etl].[usp_Load_DimEmployee];
            EXEC [etl].[usp_Load_DimShipper];
            EXEC [etl].[usp_Load_DimShipLocation];
            EXEC [etl].[usp_Load_FactSales];
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
-- StoredProcedures/etl_usp_Validate.sql
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
GO
