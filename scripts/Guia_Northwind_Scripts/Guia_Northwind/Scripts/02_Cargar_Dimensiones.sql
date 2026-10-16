/* Carga de dimensiones del proyecto NorthwindDW */

USE [NorthwindDW];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    -- 1. Eliminar datos existentes
    DELETE FROM dbo.FactSales;
    DELETE FROM dbo.DimCustomer;
    DELETE FROM dbo.DimEmployee;
    DELETE FROM dbo.DimProduct;
    DELETE FROM dbo.DimDate;
    DELETE FROM dbo.DimShipper;

    -- 2. Reiniciar contadores de identidad si aplican
    IF OBJECTPROPERTY(OBJECT_ID('dbo.DimCustomer'), 'TableHasIdentity') = 1
        DBCC CHECKIDENT ('dbo.DimCustomer', RESEED, 0) WITH NO_INFOMSGS;

    IF OBJECTPROPERTY(OBJECT_ID('dbo.DimEmployee'), 'TableHasIdentity') = 1
        DBCC CHECKIDENT ('dbo.DimEmployee', RESEED, 0) WITH NO_INFOMSGS;

    IF OBJECTPROPERTY(OBJECT_ID('dbo.DimProduct'), 'TableHasIdentity') = 1
        DBCC CHECKIDENT ('dbo.DimProduct', RESEED, 0) WITH NO_INFOMSGS;

    IF OBJECTPROPERTY(OBJECT_ID('dbo.DimShipper'), 'TableHasIdentity') = 1
        DBCC CHECKIDENT ('dbo.DimShipper', RESEED, 0) WITH NO_INFOMSGS;

    -- 3. Cargar DimCustomer
    INSERT INTO dbo.DimCustomer (CustomerID, CompanyName, ContactName, City, Region, Country)
    SELECT c.CustomerID, c.CompanyName, c.ContactName, c.City, c.Region, c.Country
    FROM Northwind.dbo.Customers AS c;

    -- 4. Cargar DimEmployee
    INSERT INTO dbo.DimEmployee (
        EmployeeID, 
        LastName, 
        FirstName, 
        Title, 
        TitleOfCourtesy, 
        BirthDate, 
        HireDate, 
        Address, 
        City, 
        Region, 
        PostalCode, 
        Country
    )
    SELECT 
        e.EmployeeID, 
        e.LastName, 
        e.FirstName, 
        e.Title, 
        e.TitleOfCourtesy, 
        e.BirthDate, 
        e.HireDate, 
        e.Address, 
        e.City, 
        e.Region, 
        e.PostalCode, 
        e.Country
    FROM Northwind.dbo.Employees AS e;

    -- 5. Cargar DimProduct (Corregido con la estructura real de dbo.DimProduct)
    INSERT INTO dbo.DimProduct (
        ProductID, 
        ProductName, 
        QuantityPerUnit, 
        UnitPrice, 
        UnitsInStock, 
        UnitsOnOrder, 
        ReorderLevel, 
        Discontinued, 
        CategoryID, 
        CategoryName, 
        CategoryDescription, 
        SupplierID, 
        SupplierCompanyName
    )
    SELECT 
        p.ProductID, 
        p.ProductName, 
        p.QuantityPerUnit, 
        p.UnitPrice, 
        p.UnitsInStock, 
        p.UnitsOnOrder, 
        p.ReorderLevel, 
        p.Discontinued, 
        p.CategoryID, 
        c.CategoryName, 
        c.Description, 
        p.SupplierID, 
        s.CompanyName
    FROM Northwind.dbo.Products AS p
    LEFT JOIN Northwind.dbo.Categories AS c ON c.CategoryID = p.CategoryID
    LEFT JOIN Northwind.dbo.Suppliers AS s ON s.SupplierID = p.SupplierID;

    -- 6. Cargar DimShipper
    INSERT INTO dbo.DimShipper (ShipperID, CompanyName)
    SELECT s.ShipperID, s.CompanyName
    FROM Northwind.dbo.Shippers AS s;

    -- 7. Cargar DimDate
    ;WITH Fechas AS (
        SELECT DISTINCT CAST(OrderDate AS date) AS Fecha
        FROM Northwind.dbo.Orders
        WHERE OrderDate IS NOT NULL
    )
    INSERT INTO dbo.DimDate (
        DateKey,
        FullDate,
        DayOfMonth,
        DayName,
        MonthNumber,
        MonthName,
        QuarterNumber,
        YearNumber,
        MonthYear
    )
    SELECT 
        CONVERT(int, CONVERT(char(8), Fecha, 112)), 
        Fecha,
        DAY(Fecha),
        CASE ((DATEDIFF(DAY, CONVERT(date,'19000101'), Fecha) % 7) + 1)
            WHEN 1 THEN N'Lunes' WHEN 2 THEN N'Martes' WHEN 3 THEN N'Miércoles'
            WHEN 4 THEN N'Jueves' WHEN 5 THEN N'Viernes' WHEN 6 THEN N'Sábado' ELSE N'Domingo' 
        END,
        MONTH(Fecha),
        CASE MONTH(Fecha)
            WHEN 1 THEN N'Enero' WHEN 2 THEN N'Febrero' WHEN 3 THEN N'Marzo'
            WHEN 4 THEN N'Abril' WHEN 5 THEN N'Mayo' WHEN 6 THEN N'Junio'
            WHEN 7 THEN N'Julio' WHEN 8 THEN N'Agosto' WHEN 9 THEN N'Septiembre'
            WHEN 10 THEN N'Octubre' WHEN 11 THEN N'Noviembre' ELSE N'Diciembre' 
        END,
        DATEPART(QUARTER, Fecha),
        YEAR(Fecha),
        CONVERT(char(7), Fecha, 120)
    FROM Fechas;

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
GO

/* Verificación de registros cargados */
SELECT 'DimCustomer' AS Tabla, COUNT(*) AS Filas FROM dbo.DimCustomer
UNION ALL SELECT 'DimEmployee', COUNT(*) FROM dbo.DimEmployee
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimDate', COUNT(*) FROM dbo.DimDate
UNION ALL SELECT 'DimShipper', COUNT(*) FROM dbo.DimShipper;
GO
