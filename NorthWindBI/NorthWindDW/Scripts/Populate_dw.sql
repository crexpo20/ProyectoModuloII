/* ==========================================================
   05_populate_dw.sql
   Carga el modelo estrella desde el OLTP Northwind:
     1) Staging  : copia cruda del OLTP (TRUNCATE + INSERT)
     2) Dimensiones SCD Tipo 2 : DimCustomer, DimProduct, DimEmployee,
                                 DimShipper, DimShipGeography
     3) FactSales: una fila por línea de pedido (carga incremental por OrderID)

   Re-ejecutable: no duplica datos. Si un atributo cambia en el origen,
   cierra la versión vigente (IsCurrent = 0) y crea una nueva.

   ANTES DE EJECUTAR:
     - Cambiar el USE si el DW se llama distinto (p. ej. NorthwindDW2)
     - Cambiar @SourceDb si la base OLTP no se llama 'Northwind'
     - El OLTP debe tener DATOS (no solo las tablas)
     - Estar en la misma instancia de SQL Server que el OLTP
   ========================================================== */
USE [NorthwindDW];   -- <<< nombre de la base del DW
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SourceDb sysname = N'Northwind';          -- <<< nombre de la base OLTP
DECLARE @Today    date    = CAST(GETDATE() AS date);
DECLARE @BatchID  int, @sql nvarchar(max), @rows int;

DROP TABLE IF EXISTS #src_customer, #src_product, #src_employee, #src_shipper, #src_geo;

INSERT etl.LoadBatch DEFAULT VALUES;
SET @BatchID = SCOPE_IDENTITY();

BEGIN TRY

    IF DB_ID(@SourceDb) IS NULL
        THROW 50000, N'La base OLTP indicada en @SourceDb no existe en esta instancia.', 1;

    BEGIN TRAN;

    /* ======================================================
       1) STAGING
       ====================================================== */
    TRUNCATE TABLE stg.OrderDetails;
    TRUNCATE TABLE stg.Orders;
    TRUNCATE TABLE stg.Shippers;
    TRUNCATE TABLE stg.Employees;
    TRUNCATE TABLE stg.Products;
    TRUNCATE TABLE stg.Categories;
    TRUNCATE TABLE stg.Suppliers;
    TRUNCATE TABLE stg.Customers;

    SET @sql = N'INSERT stg.Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, ETLBatchID)
        SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Customers;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Suppliers (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, HomePage, ETLBatchID)
        SELECT SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, HomePage, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Suppliers;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Categories (CategoryID, CategoryName, Description, ETLBatchID)
        SELECT CategoryID, CategoryName, Description, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Categories;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Products (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued, ETLBatchID)
        SELECT ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Products;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Employees (EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, ReportsTo, PhotoPath, ETLBatchID)
        SELECT EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, ReportsTo, PhotoPath, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Employees;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Shippers (ShipperID, CompanyName, Phone, ETLBatchID)
        SELECT ShipperID, CompanyName, Phone, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Shippers;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.Orders (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, ETLBatchID)
        SELECT OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.Orders;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    SET @sql = N'INSERT stg.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount, ETLBatchID)
        SELECT OrderID, ProductID, UnitPrice, Quantity, Discount, @BatchID
        FROM ' + QUOTENAME(@SourceDb) + N'.dbo.OrderDetails;';
    EXEC sp_executesql @sql, N'@BatchID int', @BatchID = @BatchID;

    IF NOT EXISTS (SELECT 1 FROM stg.Orders) OR NOT EXISTS (SELECT 1 FROM stg.OrderDetails)
        THROW 50001, N'El OLTP no tiene datos en Orders / OrderDetails. Cargue primero los datos de Northwind.', 1;

    SELECT @rows = COUNT(*) FROM stg.OrderDetails;

    /* ======================================================
       2) DIMENSIONES SCD TIPO 2
       Patrón por dimensión:
         a) calcular RowHash de los atributos en el origen
         b) cerrar versiones vigentes cuyo hash cambió
         c) insertar versión nueva (llaves nuevas o cambiadas)
       Fecha de inicio de la versión:
         - llave nunca vista     -> 1900-01-01 (cubre todo el histórico)
         - llave con cambios     -> fecha de hoy
       ====================================================== */

    /* ---------- DimCustomer ---------- */
    SELECT s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City,
           s.Region, s.PostalCode, s.Country, s.Phone, s.Fax,
           HASHBYTES('SHA2_256', CONCAT(s.CompanyName, N'|', s.ContactName, N'|', s.ContactTitle, N'|', s.Address, N'|',
                     s.City, N'|', s.Region, N'|', s.PostalCode, N'|', s.Country, N'|', s.Phone, N'|', s.Fax)) AS RowHash
    INTO #src_customer
    FROM stg.Customers s;

    UPDATE d SET RowExpirationDate = @Today, IsCurrent = 0
    FROM dw.DimCustomer d
    JOIN #src_customer s ON s.CustomerID = d.CustomerID
    WHERE d.IsCurrent = 1 AND d.CustomerSK <> -1 AND (d.RowHash IS NULL OR d.RowHash <> s.RowHash);

    INSERT dw.DimCustomer (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode,
                           Country, Phone, Fax, RowEffectiveDate, RowExpirationDate, IsCurrent, RowHash, ETLBatchID)
    SELECT s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode,
           s.Country, s.Phone, s.Fax,
           CASE WHEN EXISTS (SELECT 1 FROM dw.DimCustomer x WHERE x.CustomerID = s.CustomerID) THEN @Today ELSE CAST('1900-01-01' AS date) END,
           '9999-12-31', 1, s.RowHash, @BatchID
    FROM #src_customer s
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimCustomer d WHERE d.CustomerID = s.CustomerID AND d.IsCurrent = 1);

    /* ---------- DimProduct (absorbe Categories y Suppliers) ---------- */
    SELECT x.*,
           HASHBYTES('SHA2_256', CONCAT(x.ProductName, N'|', x.QuantityPerUnit, N'|', x.ListPrice, N'|', x.ReorderLevel, N'|',
                     x.IsDiscontinued, N'|', x.CategoryID, N'|', x.CategoryName, N'|', x.CategoryDescription, N'|',
                     x.SupplierID, N'|', x.SupplierName, N'|', x.SupplierContactName, N'|', x.SupplierContactTitle, N'|',
                     x.SupplierAddress, N'|', x.SupplierCity, N'|', x.SupplierRegion, N'|', x.SupplierPostalCode, N'|',
                     x.SupplierCountry, N'|', x.SupplierPhone, N'|', x.SupplierHomePage)) AS RowHash
    INTO #src_product
    FROM (
        SELECT p.ProductID, p.ProductName, p.QuantityPerUnit,
               CAST(p.UnitPrice AS decimal(19,4)) AS ListPrice,
               p.ReorderLevel, p.Discontinued AS IsDiscontinued,
               p.CategoryID, c.CategoryName,
               CAST(c.Description AS nvarchar(500)) AS CategoryDescription,
               p.SupplierID, sp.CompanyName AS SupplierName, sp.ContactName AS SupplierContactName,
               sp.ContactTitle AS SupplierContactTitle, sp.Address AS SupplierAddress, sp.City AS SupplierCity,
               sp.Region AS SupplierRegion, sp.PostalCode AS SupplierPostalCode, sp.Country AS SupplierCountry,
               sp.Phone AS SupplierPhone,
               CAST(sp.HomePage AS nvarchar(400)) AS SupplierHomePage
        FROM stg.Products p
        LEFT JOIN stg.Categories c  ON c.CategoryID  = p.CategoryID
        LEFT JOIN stg.Suppliers  sp ON sp.SupplierID = p.SupplierID
    ) x;

    UPDATE d SET RowExpirationDate = @Today, IsCurrent = 0
    FROM dw.DimProduct d
    JOIN #src_product s ON s.ProductID = d.ProductID
    WHERE d.IsCurrent = 1 AND d.ProductSK <> -1 AND (d.RowHash IS NULL OR d.RowHash <> s.RowHash);

    INSERT dw.DimProduct (ProductID, ProductName, QuantityPerUnit, ListPrice, ReorderLevel, IsDiscontinued,
                          CategoryID, CategoryName, CategoryDescription,
                          SupplierID, SupplierName, SupplierContactName, SupplierContactTitle, SupplierAddress,
                          SupplierCity, SupplierRegion, SupplierPostalCode, SupplierCountry, SupplierPhone, SupplierHomePage,
                          RowEffectiveDate, RowExpirationDate, IsCurrent, RowHash, ETLBatchID)
    SELECT s.ProductID, s.ProductName, s.QuantityPerUnit, s.ListPrice, s.ReorderLevel, s.IsDiscontinued,
           s.CategoryID, s.CategoryName, s.CategoryDescription,
           s.SupplierID, s.SupplierName, s.SupplierContactName, s.SupplierContactTitle, s.SupplierAddress,
           s.SupplierCity, s.SupplierRegion, s.SupplierPostalCode, s.SupplierCountry, s.SupplierPhone, s.SupplierHomePage,
           CASE WHEN EXISTS (SELECT 1 FROM dw.DimProduct x WHERE x.ProductID = s.ProductID) THEN @Today ELSE CAST('1900-01-01' AS date) END,
           '9999-12-31', 1, s.RowHash, @BatchID
    FROM #src_product s
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimProduct d WHERE d.ProductID = s.ProductID AND d.IsCurrent = 1);

    /* ---------- DimEmployee (jerarquía ReportsTo aplanada) ---------- */
    SELECT x.*,
           HASHBYTES('SHA2_256', CONCAT(x.LastName, N'|', x.FirstName, N'|', x.Title, N'|', x.TitleOfCourtesy, N'|',
                     x.BirthDate, N'|', x.HireDate, N'|', x.Address, N'|', x.City, N'|', x.Region, N'|', x.PostalCode, N'|',
                     x.Country, N'|', x.HomePhone, N'|', x.Extension, N'|', x.PhotoPath, N'|',
                     x.ManagerEmployeeID, N'|', x.ManagerFullName, N'|', x.ManagerTitle)) AS RowHash
    INTO #src_employee
    FROM (
        SELECT e.EmployeeID, e.LastName, e.FirstName,
               CAST(CONCAT(e.FirstName, N' ', e.LastName) AS nvarchar(31)) AS FullName,
               e.Title, e.TitleOfCourtesy,
               CAST(e.BirthDate AS date) AS BirthDate, CAST(e.HireDate AS date) AS HireDate,
               e.Address, e.City, e.Region, e.PostalCode, e.Country, e.HomePhone, e.Extension, e.PhotoPath,
               e.ReportsTo AS ManagerEmployeeID,
               CASE WHEN m.EmployeeID IS NULL THEN NULL
                    ELSE CAST(CONCAT(m.FirstName, N' ', m.LastName) AS nvarchar(31)) END AS ManagerFullName,
               m.Title AS ManagerTitle
        FROM stg.Employees e
        LEFT JOIN stg.Employees m ON m.EmployeeID = e.ReportsTo
    ) x;

    UPDATE d SET RowExpirationDate = @Today, IsCurrent = 0
    FROM dw.DimEmployee d
    JOIN #src_employee s ON s.EmployeeID = d.EmployeeID
    WHERE d.IsCurrent = 1 AND d.EmployeeSK <> -1 AND (d.RowHash IS NULL OR d.RowHash <> s.RowHash);

    INSERT dw.DimEmployee (EmployeeID, LastName, FirstName, FullName, Title, TitleOfCourtesy, BirthDate, HireDate,
                           Address, City, Region, PostalCode, Country, HomePhone, Extension, PhotoPath,
                           ManagerEmployeeID, ManagerFullName, ManagerTitle,
                           RowEffectiveDate, RowExpirationDate, IsCurrent, RowHash, ETLBatchID)
    SELECT s.EmployeeID, s.LastName, s.FirstName, s.FullName, s.Title, s.TitleOfCourtesy, s.BirthDate, s.HireDate,
           s.Address, s.City, s.Region, s.PostalCode, s.Country, s.HomePhone, s.Extension, s.PhotoPath,
           s.ManagerEmployeeID, s.ManagerFullName, s.ManagerTitle,
           CASE WHEN EXISTS (SELECT 1 FROM dw.DimEmployee x WHERE x.EmployeeID = s.EmployeeID) THEN @Today ELSE CAST('1900-01-01' AS date) END,
           '9999-12-31', 1, s.RowHash, @BatchID
    FROM #src_employee s
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimEmployee d WHERE d.EmployeeID = s.EmployeeID AND d.IsCurrent = 1);

    /* ---------- DimShipper ---------- */
    SELECT s.ShipperID, s.CompanyName, s.Phone,
           HASHBYTES('SHA2_256', CONCAT(s.CompanyName, N'|', s.Phone)) AS RowHash
    INTO #src_shipper
    FROM stg.Shippers s;

    UPDATE d SET RowExpirationDate = @Today, IsCurrent = 0
    FROM dw.DimShipper d
    JOIN #src_shipper s ON s.ShipperID = d.ShipperID
    WHERE d.IsCurrent = 1 AND d.ShipperSK <> -1 AND (d.RowHash IS NULL OR d.RowHash <> s.RowHash);

    INSERT dw.DimShipper (ShipperID, CompanyName, Phone, RowEffectiveDate, RowExpirationDate, IsCurrent, RowHash, ETLBatchID)
    SELECT s.ShipperID, s.CompanyName, s.Phone,
           CASE WHEN EXISTS (SELECT 1 FROM dw.DimShipper x WHERE x.ShipperID = s.ShipperID) THEN @Today ELSE CAST('1900-01-01' AS date) END,
           '9999-12-31', 1, s.RowHash, @BatchID
    FROM #src_shipper s
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimShipper d WHERE d.ShipperID = s.ShipperID AND d.IsCurrent = 1);

    /* ---------- DimShipGeography (la llave es la combinación de los 4 campos) ---------- */
    SELECT g.ShipCity, g.ShipRegion, g.ShipPostalCode, g.ShipCountry,
           HASHBYTES('SHA2_256', CONCAT(g.ShipCity, N'|', g.ShipRegion, N'|', g.ShipPostalCode, N'|', g.ShipCountry)) AS RowHash
    INTO #src_geo
    FROM (SELECT DISTINCT ShipCity, ShipRegion, ShipPostalCode, ShipCountry FROM stg.Orders) g;

    INSERT dw.DimShipGeography (ShipCity, ShipRegion, ShipPostalCode, ShipCountry,
                                RowEffectiveDate, RowExpirationDate, IsCurrent, RowHash, ETLBatchID)
    SELECT s.ShipCity, s.ShipRegion, s.ShipPostalCode, s.ShipCountry,
           '1900-01-01', '9999-12-31', 1, s.RowHash, @BatchID
    FROM #src_geo s
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimShipGeography d WHERE d.IsCurrent = 1 AND d.RowHash = s.RowHash);

    /* ======================================================
       3) FACTSALES  (grano: línea de pedido)
       - Solo carga pedidos que aún no están en la fact (incremental)
       - Lookup SCD2: versión de la dimensión vigente en la fecha del pedido
       - Flete del pedido prorrateado por peso de NetAmount
       ====================================================== */
    ;WITH L AS (
        SELECT o.OrderID, o.CustomerID, o.EmployeeID, o.ShipVia,
               CAST(o.OrderDate    AS date) AS OrderDate,
               CAST(o.RequiredDate AS date) AS RequiredDate,
               CAST(o.ShippedDate  AS date) AS ShippedDate,
               CAST(ISNULL(o.Freight, 0) AS decimal(19,4)) AS Freight,
               HASHBYTES('SHA2_256', CONCAT(o.ShipCity, N'|', o.ShipRegion, N'|', o.ShipPostalCode, N'|', o.ShipCountry)) AS GeoHash,
               od.ProductID, od.Quantity,
               CAST(od.UnitPrice AS decimal(19,4)) AS UnitPrice,
               CAST(od.Discount  AS decimal(5,4))  AS Discount
        FROM stg.OrderDetails od
        JOIN stg.Orders o ON o.OrderID = od.OrderID
        WHERE NOT EXISTS (SELECT 1 FROM dw.FactSales f WHERE f.OrderID = o.OrderID)
    ),
    A AS (
        SELECT L.*, CAST(L.Quantity * L.UnitPrice AS decimal(19,4)) AS GrossAmount FROM L
    ),
    B AS (
        SELECT A.*, CAST(A.GrossAmount * A.Discount AS decimal(19,4)) AS DiscountAmount FROM A
    ),
    C AS (
        SELECT B.*,
               B.GrossAmount - B.DiscountAmount AS NetAmount,
               SUM(B.GrossAmount - B.DiscountAmount) OVER (PARTITION BY B.OrderID) AS OrderNet,
               COUNT(*) OVER (PARTITION BY B.OrderID) AS LinesInOrder
        FROM B
    )
    INSERT dw.FactSales (OrderDateKey, RequiredDateKey, ShippedDateKey,
                         CustomerKey, ProductKey, EmployeeKey, ShipperKey, ShipGeographyKey,
                         OrderID, Quantity, UnitPrice, Discount,
                         GrossAmount, DiscountAmount, NetAmount, FreightAllocated, ETLBatchID)
    SELECT ISNULL(dOrd.DateKey, -1),
           ISNULL(dReq.DateKey, -1),
           ISNULL(dShp.DateKey, -1),
           ISNULL(dc.CustomerSK, -1),
           ISNULL(dp.ProductSK, -1),
           ISNULL(de.EmployeeSK, -1),
           ISNULL(ds.ShipperSK, -1),
           ISNULL(dg.ShipGeographySK, -1),
           C.OrderID, C.Quantity, C.UnitPrice, C.Discount,
           C.GrossAmount, C.DiscountAmount, C.NetAmount,
           CAST(CASE WHEN C.OrderNet = 0 THEN C.Freight / C.LinesInOrder
                     ELSE C.Freight * C.NetAmount / C.OrderNet END AS decimal(19,4)),
           @BatchID
    FROM C
    LEFT JOIN dw.DimDate dOrd ON dOrd.FullDate = C.OrderDate
    LEFT JOIN dw.DimDate dReq ON dReq.FullDate = C.RequiredDate
    LEFT JOIN dw.DimDate dShp ON dShp.FullDate = C.ShippedDate
    LEFT JOIN dw.DimCustomer dc ON dc.CustomerID = C.CustomerID
                               AND C.OrderDate >= dc.RowEffectiveDate AND C.OrderDate < dc.RowExpirationDate
    LEFT JOIN dw.DimProduct  dp ON dp.ProductID  = C.ProductID
                               AND C.OrderDate >= dp.RowEffectiveDate AND C.OrderDate < dp.RowExpirationDate
    LEFT JOIN dw.DimEmployee de ON de.EmployeeID = C.EmployeeID
                               AND C.OrderDate >= de.RowEffectiveDate AND C.OrderDate < de.RowExpirationDate
    LEFT JOIN dw.DimShipper  ds ON ds.ShipperID  = C.ShipVia
                               AND C.OrderDate >= ds.RowEffectiveDate AND C.OrderDate < ds.RowExpirationDate
    LEFT JOIN dw.DimShipGeography dg ON dg.IsCurrent = 1 AND dg.RowHash = C.GeoHash
    ORDER BY C.OrderID, C.ProductID;

    COMMIT TRAN;

    UPDATE etl.LoadBatch
    SET EndTime = SYSDATETIME(), Status = 'SUCCESS', RowsExtracted = @rows
    WHERE ETLBatchID = @BatchID;

    PRINT N'Carga completada. ETLBatchID = ' + CAST(@BatchID AS nvarchar(10));

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;

    UPDATE etl.LoadBatch
    SET EndTime = SYSDATETIME(), Status = 'FAILED', ErrorMessage = LEFT(ERROR_MESSAGE(), 4000)
    WHERE ETLBatchID = @BatchID;

    THROW;
END CATCH;

DROP TABLE IF EXISTS #src_customer, #src_product, #src_employee, #src_shipper, #src_geo;
GO

/* ==========================================================
   VERIFICACIÓN
   ========================================================== */

-- Filas por tabla
SELECT 'DimDate' AS tabla, COUNT(*) AS filas FROM dw.DimDate
UNION ALL SELECT 'DimCustomer',      COUNT(*) FROM dw.DimCustomer
UNION ALL SELECT 'DimProduct',       COUNT(*) FROM dw.DimProduct
UNION ALL SELECT 'DimEmployee',      COUNT(*) FROM dw.DimEmployee
UNION ALL SELECT 'DimShipper',       COUNT(*) FROM dw.DimShipper
UNION ALL SELECT 'DimShipGeography', COUNT(*) FROM dw.DimShipGeography
UNION ALL SELECT 'FactSales',        COUNT(*) FROM dw.FactSales;

-- Reconciliación contra el origen (las diferencias deben ser mínimas por redondeo)
SELECT (SELECT SUM(NetAmount) FROM dw.FactSales)                                                              AS NetoDW,
       (SELECT SUM(CAST(UnitPrice AS decimal(19,4)) * Quantity * (1 - CAST(Discount AS decimal(9,6))))
          FROM stg.OrderDetails)                                                                              AS NetoOrigen,
       (SELECT SUM(FreightAllocated) FROM dw.FactSales)                                                       AS FleteDW,
       (SELECT SUM(CAST(Freight AS decimal(19,4))) FROM stg.Orders o
          WHERE EXISTS (SELECT 1 FROM stg.OrderDetails d WHERE d.OrderID = o.OrderID))                        AS FleteOrigen;

-- Líneas con alguna dimensión "Desconocido" (debería ser 0, salvo pedidos sin enviar)
SELECT SUM(CASE WHEN CustomerKey      = -1 THEN 1 ELSE 0 END) AS sin_cliente,
       SUM(CASE WHEN ProductKey       = -1 THEN 1 ELSE 0 END) AS sin_producto,
       SUM(CASE WHEN EmployeeKey      = -1 THEN 1 ELSE 0 END) AS sin_empleado,
       SUM(CASE WHEN ShipperKey       = -1 THEN 1 ELSE 0 END) AS sin_transportista,
       SUM(CASE WHEN ShipGeographyKey = -1 THEN 1 ELSE 0 END) AS sin_destino,
       SUM(CASE WHEN ShippedDateKey   = -1 THEN 1 ELSE 0 END) AS sin_fecha_envio
FROM dw.FactSales;

-- Ejemplo de consulta analítica: ventas netas por año y categoría
SELECT dd.YearNumber AS anio, p.CategoryName AS categoria, SUM(f.NetAmount) AS ventas_netas
FROM dw.FactSales f
JOIN dw.DimDate    dd ON dd.DateKey   = f.OrderDateKey
JOIN dw.DimProduct p  ON p.ProductSK  = f.ProductKey
GROUP BY dd.YearNumber, p.CategoryName
ORDER BY dd.YearNumber, ventas_netas DESC;
GO