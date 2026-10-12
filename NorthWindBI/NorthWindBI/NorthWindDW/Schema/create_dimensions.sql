/* ==========================================================
   02_create_dimensions.sql
   Dimensiones del modelo estrella Northwind.
   Convenciones:
     - XxxSK  : llave subrogada (IDENTITY), PK de la dimensión
     - XxxID  : llave natural del OLTP (business key)
     - SCD Tipo 2: RowEffectiveDate / RowExpirationDate / IsCurrent / RowHash
     - SK = -1 : miembro "Desconocido" para evitar NULLs en la tabla de hechos
   Ejecutar UNA sola vez sobre una base vacía.
   ========================================================== */
USE [prueba]
GO

/* ==========================================================
   DimDate  (rol múltiple: Order / Required / Shipped)
   Llave inteligente YYYYMMDD; dimensión estática (sin SCD)
   ========================================================== */
CREATE TABLE dw.DimDate(
    DateKey          int          NOT NULL,   -- YYYYMMDD, -1 = desconocida / no enviada
    FullDate         date         NOT NULL,
    DayOfWeekNumber  tinyint      NOT NULL,   -- ISO: 1 = Lunes ... 7 = Domingo
    DayName          nvarchar(10) NOT NULL,
    DayOfMonth       tinyint      NOT NULL,
    DayOfYear        smallint     NOT NULL,
    WeekOfYearISO    tinyint      NOT NULL,
    MonthNumber      tinyint      NOT NULL,
    MonthName        nvarchar(12) NOT NULL,
    QuarterNumber    tinyint      NOT NULL,
    QuarterName      nchar(2)     NOT NULL,   -- T1..T4
    YearNumber       smallint     NOT NULL,
    YearMonth        char(7)      NOT NULL,   -- 1997-03
    YearQuarter      char(7)      NOT NULL,   -- 1997-T1
    IsWeekend        bit          NOT NULL,
    CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (DateKey),
    CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
);
GO

-- Miembro desconocido (p. ej. pedidos aún no enviados -> ShippedDate NULL)
INSERT dw.DimDate (DateKey, FullDate, DayOfWeekNumber, DayName, DayOfMonth, DayOfYear, WeekOfYearISO,
                   MonthNumber, MonthName, QuarterNumber, QuarterName, YearNumber, YearMonth, YearQuarter, IsWeekend)
VALUES (-1, '1900-01-01', 1, N'N/D', 1, 1, 1, 1, N'N/D', 1, N'T1', 1900, '1900-01', '1900-T1', 0);
GO

-- Poblado 1995-01-01 .. 2030-12-31
DECLARE @Start date = '1995-01-01', @End date = '2030-12-31';

;WITH d AS (
    SELECT @Start AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt) FROM d WHERE dt < @End
)
INSERT dw.DimDate (DateKey, FullDate, DayOfWeekNumber, DayName, DayOfMonth, DayOfYear, WeekOfYearISO,
                   MonthNumber, MonthName, QuarterNumber, QuarterName, YearNumber, YearMonth, YearQuarter, IsWeekend)
SELECT  CONVERT(int, CONVERT(char(8), dt, 112)),
        dt,
        x.IsoDow,
        CHOOSE(x.IsoDow, N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo'),
        DAY(dt),
        DATEPART(DAYOFYEAR, dt),
        DATEPART(ISO_WEEK, dt),
        MONTH(dt),
        CHOOSE(MONTH(dt), N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio',
                          N'Julio', N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre'),
        DATEPART(QUARTER, dt),
        CONCAT(N'T', DATEPART(QUARTER, dt)),
        YEAR(dt),
        LEFT(CONVERT(char(10), dt, 120), 7),
        CONCAT(YEAR(dt), '-T', DATEPART(QUARTER, dt)),
        CASE WHEN x.IsoDow >= 6 THEN 1 ELSE 0 END
FROM d
CROSS APPLY (SELECT ((DATEPART(WEEKDAY, dt) + @@DATEFIRST - 2) % 7) + 1 AS IsoDow) AS x
OPTION (MAXRECURSION 0);
GO

/* ==========================================================
   DimCustomer  (SCD Tipo 2)
   ========================================================== */
CREATE TABLE dw.DimCustomer(
    CustomerSK         int IDENTITY(1,1) NOT NULL,
    CustomerID         nchar(5)      NOT NULL,   -- business key
    CompanyName        nvarchar(40)  NOT NULL,
    ContactName        nvarchar(30)  NULL,
    ContactTitle       nvarchar(30)  NULL,
    Address            nvarchar(60)  NULL,
    City               nvarchar(15)  NULL,
    Region             nvarchar(15)  NULL,
    PostalCode         nvarchar(10)  NULL,
    Country            nvarchar(15)  NULL,
    Phone              nvarchar(24)  NULL,
    Fax                nvarchar(24)  NULL,
    -- Control SCD2
    RowEffectiveDate   date          NOT NULL,
    RowExpirationDate  date          NOT NULL CONSTRAINT DF_DimCustomer_Exp  DEFAULT ('9999-12-31'),
    IsCurrent          bit           NOT NULL CONSTRAINT DF_DimCustomer_Cur  DEFAULT (1),
    RowHash            varbinary(32) NULL,       -- SHA2_256 de atributos Tipo 2
    ETLBatchID         int           NULL,
    InsertedAt         datetime2(0)  NOT NULL CONSTRAINT DF_DimCustomer_Ins  DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimCustomer PRIMARY KEY CLUSTERED (CustomerSK)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimCustomer_BK_Current ON dw.DimCustomer (CustomerID) WHERE IsCurrent = 1;
CREATE NONCLUSTERED INDEX IX_DimCustomer_BK_Dates ON dw.DimCustomer (CustomerID, RowEffectiveDate, RowExpirationDate);
GO
SET IDENTITY_INSERT dw.DimCustomer ON;
INSERT dw.DimCustomer (CustomerSK, CustomerID, CompanyName, RowEffectiveDate)
VALUES (-1, N'-1', N'Desconocido', '1900-01-01');
SET IDENTITY_INSERT dw.DimCustomer OFF;
GO

/* ==========================================================
   DimProduct  (SCD Tipo 2) - absorbe Categories y Suppliers
   ========================================================== */
CREATE TABLE dw.DimProduct(
    ProductSK            int IDENTITY(1,1) NOT NULL,
    ProductID            int            NOT NULL,   -- business key
    ProductName          nvarchar(40)   NOT NULL,
    QuantityPerUnit      nvarchar(20)   NULL,
    ListPrice            decimal(19,4)  NULL,       -- precio de lista vigente (no el cobrado)
    ReorderLevel         smallint       NULL,
    IsDiscontinued       bit            NOT NULL,
    -- Categoría (desnormalizada)
    CategoryID           int            NULL,
    CategoryName         nvarchar(15)   NULL,
    CategoryDescription  nvarchar(500)  NULL,
    -- Proveedor (desnormalizado)
    SupplierID           int            NULL,
    SupplierName         nvarchar(40)   NULL,
    SupplierContactName  nvarchar(30)   NULL,
    SupplierContactTitle nvarchar(30)   NULL,
    SupplierAddress      nvarchar(60)   NULL,
    SupplierCity         nvarchar(15)   NULL,
    SupplierRegion       nvarchar(15)   NULL,
    SupplierPostalCode   nvarchar(10)   NULL,
    SupplierCountry      nvarchar(15)   NULL,
    SupplierPhone        nvarchar(24)   NULL,
    SupplierHomePage     nvarchar(400)  NULL,
    -- Control SCD2
    RowEffectiveDate     date           NOT NULL,
    RowExpirationDate    date           NOT NULL CONSTRAINT DF_DimProduct_Exp DEFAULT ('9999-12-31'),
    IsCurrent            bit            NOT NULL CONSTRAINT DF_DimProduct_Cur DEFAULT (1),
    RowHash              varbinary(32)  NULL,
    ETLBatchID           int            NULL,
    InsertedAt           datetime2(0)   NOT NULL CONSTRAINT DF_DimProduct_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimProduct PRIMARY KEY CLUSTERED (ProductSK)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimProduct_BK_Current ON dw.DimProduct (ProductID) WHERE IsCurrent = 1;
CREATE NONCLUSTERED INDEX IX_DimProduct_BK_Dates ON dw.DimProduct (ProductID, RowEffectiveDate, RowExpirationDate);
GO
SET IDENTITY_INSERT dw.DimProduct ON;
INSERT dw.DimProduct (ProductSK, ProductID, ProductName, IsDiscontinued, CategoryName, SupplierName, RowEffectiveDate)
VALUES (-1, -1, N'Desconocido', 0, N'Desconocido', N'Desconocido', '1900-01-01');
SET IDENTITY_INSERT dw.DimProduct OFF;
GO

/* ==========================================================
   DimEmployee  (SCD Tipo 2) - jerarquía ReportsTo aplanada
   ========================================================== */
CREATE TABLE dw.DimEmployee(
    EmployeeSK         int IDENTITY(1,1) NOT NULL,
    EmployeeID         int            NOT NULL,   -- business key
    LastName           nvarchar(20)   NOT NULL,
    FirstName          nvarchar(10)   NOT NULL,
    FullName           nvarchar(31)   NOT NULL,   -- FirstName + ' ' + LastName
    Title              nvarchar(30)   NULL,
    TitleOfCourtesy    nvarchar(25)   NULL,
    BirthDate          date           NULL,
    HireDate           date           NULL,
    Address            nvarchar(60)   NULL,
    City               nvarchar(15)   NULL,
    Region             nvarchar(15)   NULL,
    PostalCode         nvarchar(10)   NULL,
    Country            nvarchar(15)   NULL,
    HomePhone          nvarchar(24)   NULL,
    Extension          nvarchar(4)    NULL,
    PhotoPath          nvarchar(255)  NULL,
    -- Jefe directo (auto-referencia aplanada)
    ManagerEmployeeID  int            NULL,
    ManagerFullName    nvarchar(31)   NULL,
    ManagerTitle       nvarchar(30)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimEmployee_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimEmployee_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimEmployee_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimEmployee PRIMARY KEY CLUSTERED (EmployeeSK)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimEmployee_BK_Current ON dw.DimEmployee (EmployeeID) WHERE IsCurrent = 1;
CREATE NONCLUSTERED INDEX IX_DimEmployee_BK_Dates ON dw.DimEmployee (EmployeeID, RowEffectiveDate, RowExpirationDate);
GO
SET IDENTITY_INSERT dw.DimEmployee ON;
INSERT dw.DimEmployee (EmployeeSK, EmployeeID, LastName, FirstName, FullName, RowEffectiveDate)
VALUES (-1, -1, N'Desconocido', N'N/D', N'N/D Desconocido', '1900-01-01');
SET IDENTITY_INSERT dw.DimEmployee OFF;
GO

/* ==========================================================
   DimShipper  (SCD Tipo 2)
   ========================================================== */
CREATE TABLE dw.DimShipper(
    ShipperSK          int IDENTITY(1,1) NOT NULL,
    ShipperID          int            NOT NULL,   -- business key
    CompanyName        nvarchar(40)   NOT NULL,
    Phone              nvarchar(24)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimShipper_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimShipper_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimShipper_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimShipper PRIMARY KEY CLUSTERED (ShipperSK)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimShipper_BK_Current ON dw.DimShipper (ShipperID) WHERE IsCurrent = 1;
CREATE NONCLUSTERED INDEX IX_DimShipper_BK_Dates ON dw.DimShipper (ShipperID, RowEffectiveDate, RowExpirationDate);
GO
SET IDENTITY_INSERT dw.DimShipper ON;
INSERT dw.DimShipper (ShipperSK, ShipperID, CompanyName, RowEffectiveDate)
VALUES (-1, -1, N'Desconocido', '1900-01-01');
SET IDENTITY_INSERT dw.DimShipper OFF;
GO

/* ==========================================================
   DimShipGeography  (destino del envío)
   Llave natural compuesta: ciudad + región + código postal + país.
   Se mantiene la estructura SCD2 por uniformidad, aunque en la práctica
   una ubicación geográfica rara vez cambia de atributos.
   ========================================================== */
CREATE TABLE dw.DimShipGeography(
    ShipGeographySK    int IDENTITY(1,1) NOT NULL,
    ShipCity           nvarchar(15)   NULL,
    ShipRegion         nvarchar(15)   NULL,
    ShipPostalCode     nvarchar(10)   NULL,
    ShipCountry        nvarchar(15)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimShipGeo_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimShipGeo_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimShipGeo_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimShipGeography PRIMARY KEY CLUSTERED (ShipGeographySK)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_DimShipGeo_BK_Current
    ON dw.DimShipGeography (ShipCity, ShipRegion, ShipPostalCode, ShipCountry) WHERE IsCurrent = 1;
GO
SET IDENTITY_INSERT dw.DimShipGeography ON;
INSERT dw.DimShipGeography (ShipGeographySK, ShipCity, ShipCountry, RowEffectiveDate)
VALUES (-1, N'Desconocido', N'Desconocido', '1900-01-01');
SET IDENTITY_INSERT dw.DimShipGeography OFF;
GO