/*
Script de implementación para  NorthWindDW

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName " NorthWindDW"
:setvar DefaultFilePrefix " NorthWindDW"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detecte el modo SQLCMD y deshabilite la ejecución de scripts si no se admite el modo SQLCMD.
Para volver a habilitar el script después de habilitar el modo SQLCMD, ejecute lo siguiente:
ESTABLECER NOEXEC DESACTIVADO; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Creando Esquema [dw]...';


GO
CREATE SCHEMA [dw]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [etl]...';


GO
CREATE SCHEMA [etl]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Esquema [stg]...';


GO
CREATE SCHEMA [stg]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Tabla [dw].[FactSales]...';


GO
CREATE TABLE [dw].[FactSales] (
    [SalesKey]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [OrderDateKey]     INT             NOT NULL,
    [RequiredDateKey]  INT             NOT NULL,
    [ShippedDateKey]   INT             NOT NULL,
    [CustomerKey]      INT             NOT NULL,
    [ProductKey]       INT             NOT NULL,
    [EmployeeKey]      INT             NOT NULL,
    [ShipperKey]       INT             NOT NULL,
    [ShipGeographyKey] INT             NOT NULL,
    [OrderID]          INT             NOT NULL,
    [Quantity]         SMALLINT        NOT NULL,
    [UnitPrice]        DECIMAL (19, 4) NOT NULL,
    [Discount]         DECIMAL (5, 4)  NOT NULL,
    [GrossAmount]      DECIMAL (19, 4) NOT NULL,
    [DiscountAmount]   DECIMAL (19, 4) NOT NULL,
    [NetAmount]        DECIMAL (19, 4) NOT NULL,
    [FreightAllocated] DECIMAL (19, 4) NOT NULL,
    [ETLBatchID]       INT             NULL,
    [LoadDateTime]     DATETIME2 (0)   NOT NULL,
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([SalesKey] ASC),
    CONSTRAINT [UQ_FactSales_Grain] UNIQUE NONCLUSTERED ([OrderID] ASC, [ProductKey] ASC)
);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_OrderDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDate]
    ON [dw].[FactSales]([OrderDateKey] ASC)
    INCLUDE([NetAmount], [Quantity]);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_Customer]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_Customer]
    ON [dw].[FactSales]([CustomerKey] ASC)
    INCLUDE([NetAmount]);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_Product]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_Product]
    ON [dw].[FactSales]([ProductKey] ASC)
    INCLUDE([NetAmount], [Quantity]);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_Employee]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_Employee]
    ON [dw].[FactSales]([EmployeeKey] ASC)
    INCLUDE([NetAmount]);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_Shipper]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_Shipper]
    ON [dw].[FactSales]([ShipperKey] ASC)
    INCLUDE([FreightAllocated]);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_ShipDate]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipDate]
    ON [dw].[FactSales]([ShippedDateKey] ASC);


GO
PRINT N'Creando Índice [dw].[FactSales].[IX_FactSales_ShipGeo]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipGeo]
    ON [dw].[FactSales]([ShipGeographyKey] ASC);


GO
PRINT N'Creando Tabla [dw].[DimShipper]...';


GO
CREATE TABLE [dw].[DimShipper] (
    [ShipperSK]         INT            IDENTITY (1, 1) NOT NULL,
    [ShipperID]         INT            NOT NULL,
    [CompanyName]       NVARCHAR (40)  NOT NULL,
    [Phone]             NVARCHAR (24)  NULL,
    [RowEffectiveDate]  DATE           NOT NULL,
    [RowExpirationDate] DATE           NOT NULL,
    [IsCurrent]         BIT            NOT NULL,
    [RowHash]           VARBINARY (32) NULL,
    [ETLBatchID]        INT            NULL,
    [InsertedAt]        DATETIME2 (0)  NOT NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED ([ShipperSK] ASC)
);


GO
PRINT N'Creando Índice [dw].[DimShipper].[UX_DimShipper_BK_Current]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimShipper_BK_Current]
    ON [dw].[DimShipper]([ShipperID] ASC) WHERE IsCurrent = 1;


GO
PRINT N'Creando Índice [dw].[DimShipper].[IX_DimShipper_BK_Dates]...';


GO
CREATE NONCLUSTERED INDEX [IX_DimShipper_BK_Dates]
    ON [dw].[DimShipper]([ShipperID] ASC, [RowEffectiveDate] ASC, [RowExpirationDate] ASC);


GO
PRINT N'Creando Tabla [dw].[DimShipGeography]...';


GO
CREATE TABLE [dw].[DimShipGeography] (
    [ShipGeographySK]   INT            IDENTITY (1, 1) NOT NULL,
    [ShipCity]          NVARCHAR (15)  NULL,
    [ShipRegion]        NVARCHAR (15)  NULL,
    [ShipPostalCode]    NVARCHAR (10)  NULL,
    [ShipCountry]       NVARCHAR (15)  NULL,
    [RowEffectiveDate]  DATE           NOT NULL,
    [RowExpirationDate] DATE           NOT NULL,
    [IsCurrent]         BIT            NOT NULL,
    [RowHash]           VARBINARY (32) NULL,
    [ETLBatchID]        INT            NULL,
    [InsertedAt]        DATETIME2 (0)  NOT NULL,
    CONSTRAINT [PK_DimShipGeography] PRIMARY KEY CLUSTERED ([ShipGeographySK] ASC)
);


GO
PRINT N'Creando Índice [dw].[DimShipGeography].[UX_DimShipGeo_BK_Current]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimShipGeo_BK_Current]
    ON [dw].[DimShipGeography]([ShipCity] ASC, [ShipRegion] ASC, [ShipPostalCode] ASC, [ShipCountry] ASC) WHERE IsCurrent = 1;


GO
PRINT N'Creando Tabla [dw].[DimProduct]...';


GO
CREATE TABLE [dw].[DimProduct] (
    [ProductSK]            INT             IDENTITY (1, 1) NOT NULL,
    [ProductID]            INT             NOT NULL,
    [ProductName]          NVARCHAR (40)   NOT NULL,
    [QuantityPerUnit]      NVARCHAR (20)   NULL,
    [ListPrice]            DECIMAL (19, 4) NULL,
    [ReorderLevel]         SMALLINT        NULL,
    [IsDiscontinued]       BIT             NOT NULL,
    [CategoryID]           INT             NULL,
    [CategoryName]         NVARCHAR (15)   NULL,
    [CategoryDescription]  NVARCHAR (500)  NULL,
    [SupplierID]           INT             NULL,
    [SupplierName]         NVARCHAR (40)   NULL,
    [SupplierContactName]  NVARCHAR (30)   NULL,
    [SupplierContactTitle] NVARCHAR (30)   NULL,
    [SupplierAddress]      NVARCHAR (60)   NULL,
    [SupplierCity]         NVARCHAR (15)   NULL,
    [SupplierRegion]       NVARCHAR (15)   NULL,
    [SupplierPostalCode]   NVARCHAR (10)   NULL,
    [SupplierCountry]      NVARCHAR (15)   NULL,
    [SupplierPhone]        NVARCHAR (24)   NULL,
    [SupplierHomePage]     NVARCHAR (400)  NULL,
    [RowEffectiveDate]     DATE            NOT NULL,
    [RowExpirationDate]    DATE            NOT NULL,
    [IsCurrent]            BIT             NOT NULL,
    [RowHash]              VARBINARY (32)  NULL,
    [ETLBatchID]           INT             NULL,
    [InsertedAt]           DATETIME2 (0)   NOT NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductSK] ASC)
);


GO
PRINT N'Creando Índice [dw].[DimProduct].[UX_DimProduct_BK_Current]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimProduct_BK_Current]
    ON [dw].[DimProduct]([ProductID] ASC) WHERE IsCurrent = 1;


GO
PRINT N'Creando Índice [dw].[DimProduct].[IX_DimProduct_BK_Dates]...';


GO
CREATE NONCLUSTERED INDEX [IX_DimProduct_BK_Dates]
    ON [dw].[DimProduct]([ProductID] ASC, [RowEffectiveDate] ASC, [RowExpirationDate] ASC);


GO
PRINT N'Creando Tabla [dw].[DimEmployee]...';


GO
CREATE TABLE [dw].[DimEmployee] (
    [EmployeeSK]        INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeID]        INT            NOT NULL,
    [LastName]          NVARCHAR (20)  NOT NULL,
    [FirstName]         NVARCHAR (10)  NOT NULL,
    [FullName]          NVARCHAR (31)  NOT NULL,
    [Title]             NVARCHAR (30)  NULL,
    [TitleOfCourtesy]   NVARCHAR (25)  NULL,
    [BirthDate]         DATE           NULL,
    [HireDate]          DATE           NULL,
    [Address]           NVARCHAR (60)  NULL,
    [City]              NVARCHAR (15)  NULL,
    [Region]            NVARCHAR (15)  NULL,
    [PostalCode]        NVARCHAR (10)  NULL,
    [Country]           NVARCHAR (15)  NULL,
    [HomePhone]         NVARCHAR (24)  NULL,
    [Extension]         NVARCHAR (4)   NULL,
    [PhotoPath]         NVARCHAR (255) NULL,
    [ManagerEmployeeID] INT            NULL,
    [ManagerFullName]   NVARCHAR (31)  NULL,
    [ManagerTitle]      NVARCHAR (30)  NULL,
    [RowEffectiveDate]  DATE           NOT NULL,
    [RowExpirationDate] DATE           NOT NULL,
    [IsCurrent]         BIT            NOT NULL,
    [RowHash]           VARBINARY (32) NULL,
    [ETLBatchID]        INT            NULL,
    [InsertedAt]        DATETIME2 (0)  NOT NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED ([EmployeeSK] ASC)
);


GO
PRINT N'Creando Índice [dw].[DimEmployee].[UX_DimEmployee_BK_Current]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimEmployee_BK_Current]
    ON [dw].[DimEmployee]([EmployeeID] ASC) WHERE IsCurrent = 1;


GO
PRINT N'Creando Índice [dw].[DimEmployee].[IX_DimEmployee_BK_Dates]...';


GO
CREATE NONCLUSTERED INDEX [IX_DimEmployee_BK_Dates]
    ON [dw].[DimEmployee]([EmployeeID] ASC, [RowEffectiveDate] ASC, [RowExpirationDate] ASC);


GO
PRINT N'Creando Tabla [dw].[DimDate]...';


GO
CREATE TABLE [dw].[DimDate] (
    [DateKey]         INT           NOT NULL,
    [FullDate]        DATE          NOT NULL,
    [DayOfWeekNumber] TINYINT       NOT NULL,
    [DayName]         NVARCHAR (10) NOT NULL,
    [DayOfMonth]      TINYINT       NOT NULL,
    [DayOfYear]       SMALLINT      NOT NULL,
    [WeekOfYearISO]   TINYINT       NOT NULL,
    [MonthNumber]     TINYINT       NOT NULL,
    [MonthName]       NVARCHAR (12) NOT NULL,
    [QuarterNumber]   TINYINT       NOT NULL,
    [QuarterName]     NCHAR (2)     NOT NULL,
    [YearNumber]      SMALLINT      NOT NULL,
    [YearMonth]       CHAR (7)      NOT NULL,
    [YearQuarter]     CHAR (7)      NOT NULL,
    [IsWeekend]       BIT           NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC),
    CONSTRAINT [UQ_DimDate_FullDate] UNIQUE NONCLUSTERED ([FullDate] ASC)
);


GO
PRINT N'Creando Tabla [dw].[DimCustomer]...';


GO
CREATE TABLE [dw].[DimCustomer] (
    [CustomerSK]        INT            IDENTITY (1, 1) NOT NULL,
    [CustomerID]        NCHAR (5)      NOT NULL,
    [CompanyName]       NVARCHAR (40)  NOT NULL,
    [ContactName]       NVARCHAR (30)  NULL,
    [ContactTitle]      NVARCHAR (30)  NULL,
    [Address]           NVARCHAR (60)  NULL,
    [City]              NVARCHAR (15)  NULL,
    [Region]            NVARCHAR (15)  NULL,
    [PostalCode]        NVARCHAR (10)  NULL,
    [Country]           NVARCHAR (15)  NULL,
    [Phone]             NVARCHAR (24)  NULL,
    [Fax]               NVARCHAR (24)  NULL,
    [RowEffectiveDate]  DATE           NOT NULL,
    [RowExpirationDate] DATE           NOT NULL,
    [IsCurrent]         BIT            NOT NULL,
    [RowHash]           VARBINARY (32) NULL,
    [ETLBatchID]        INT            NULL,
    [InsertedAt]        DATETIME2 (0)  NOT NULL,
    CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerSK] ASC)
);


GO
PRINT N'Creando Índice [dw].[DimCustomer].[UX_DimCustomer_BK_Current]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimCustomer_BK_Current]
    ON [dw].[DimCustomer]([CustomerID] ASC) WHERE IsCurrent = 1;


GO
PRINT N'Creando Índice [dw].[DimCustomer].[IX_DimCustomer_BK_Dates]...';


GO
CREATE NONCLUSTERED INDEX [IX_DimCustomer_BK_Dates]
    ON [dw].[DimCustomer]([CustomerID] ASC, [RowEffectiveDate] ASC, [RowExpirationDate] ASC);


GO
PRINT N'Creando Tabla [etl].[LoadBatch]...';


GO
CREATE TABLE [etl].[LoadBatch] (
    [ETLBatchID]    INT             IDENTITY (1, 1) NOT NULL,
    [StartTime]     DATETIME2 (0)   NOT NULL,
    [EndTime]       DATETIME2 (0)   NULL,
    [Status]        VARCHAR (15)    NOT NULL,
    [RowsExtracted] INT             NULL,
    [ErrorMessage]  NVARCHAR (4000) NULL,
    CONSTRAINT [PK_LoadBatch] PRIMARY KEY CLUSTERED ([ETLBatchID] ASC)
);


GO
PRINT N'Creando Tabla [stg].[Suppliers]...';


GO
CREATE TABLE [stg].[Suppliers] (
    [SupplierID]      INT            NOT NULL,
    [CompanyName]     NVARCHAR (40)  NOT NULL,
    [ContactName]     NVARCHAR (30)  NULL,
    [ContactTitle]    NVARCHAR (30)  NULL,
    [Address]         NVARCHAR (60)  NULL,
    [City]            NVARCHAR (15)  NULL,
    [Region]          NVARCHAR (15)  NULL,
    [PostalCode]      NVARCHAR (10)  NULL,
    [Country]         NVARCHAR (15)  NULL,
    [Phone]           NVARCHAR (24)  NULL,
    [Fax]             NVARCHAR (24)  NULL,
    [HomePage]        NVARCHAR (MAX) NULL,
    [ETLBatchID]      INT            NULL,
    [ExtractDateTime] DATETIME2 (0)  NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Shippers]...';


GO
CREATE TABLE [stg].[Shippers] (
    [ShipperID]       INT           NOT NULL,
    [CompanyName]     NVARCHAR (40) NOT NULL,
    [Phone]           NVARCHAR (24) NULL,
    [ETLBatchID]      INT           NULL,
    [ExtractDateTime] DATETIME2 (0) NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Products]...';


GO
CREATE TABLE [stg].[Products] (
    [ProductID]       INT           NOT NULL,
    [ProductName]     NVARCHAR (40) NOT NULL,
    [SupplierID]      INT           NULL,
    [CategoryID]      INT           NULL,
    [QuantityPerUnit] NVARCHAR (20) NULL,
    [UnitPrice]       MONEY         NULL,
    [UnitsInStock]    SMALLINT      NULL,
    [UnitsOnOrder]    SMALLINT      NULL,
    [ReorderLevel]    SMALLINT      NULL,
    [Discontinued]    BIT           NOT NULL,
    [ETLBatchID]      INT           NULL,
    [ExtractDateTime] DATETIME2 (0) NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Orders]...';


GO
CREATE TABLE [stg].[Orders] (
    [OrderID]         INT           NOT NULL,
    [CustomerID]      NCHAR (5)     NULL,
    [EmployeeID]      INT           NULL,
    [OrderDate]       DATETIME      NULL,
    [RequiredDate]    DATETIME      NULL,
    [ShippedDate]     DATETIME      NULL,
    [ShipVia]         INT           NULL,
    [Freight]         MONEY         NULL,
    [ShipName]        NVARCHAR (40) NULL,
    [ShipAddress]     NVARCHAR (60) NULL,
    [ShipCity]        NVARCHAR (15) NULL,
    [ShipRegion]      NVARCHAR (15) NULL,
    [ShipPostalCode]  NVARCHAR (10) NULL,
    [ShipCountry]     NVARCHAR (15) NULL,
    [ETLBatchID]      INT           NULL,
    [ExtractDateTime] DATETIME2 (0) NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[OrderDetails]...';


GO
CREATE TABLE [stg].[OrderDetails] (
    [OrderID]         INT           NOT NULL,
    [ProductID]       INT           NOT NULL,
    [UnitPrice]       MONEY         NOT NULL,
    [Quantity]        SMALLINT      NOT NULL,
    [Discount]        REAL          NOT NULL,
    [ETLBatchID]      INT           NULL,
    [ExtractDateTime] DATETIME2 (0) NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Employees]...';


GO
CREATE TABLE [stg].[Employees] (
    [EmployeeID]      INT            NOT NULL,
    [LastName]        NVARCHAR (20)  NOT NULL,
    [FirstName]       NVARCHAR (10)  NOT NULL,
    [Title]           NVARCHAR (30)  NULL,
    [TitleOfCourtesy] NVARCHAR (25)  NULL,
    [BirthDate]       DATETIME       NULL,
    [HireDate]        DATETIME       NULL,
    [Address]         NVARCHAR (60)  NULL,
    [City]            NVARCHAR (15)  NULL,
    [Region]          NVARCHAR (15)  NULL,
    [PostalCode]      NVARCHAR (10)  NULL,
    [Country]         NVARCHAR (15)  NULL,
    [HomePhone]       NVARCHAR (24)  NULL,
    [Extension]       NVARCHAR (4)   NULL,
    [ReportsTo]       INT            NULL,
    [PhotoPath]       NVARCHAR (255) NULL,
    [ETLBatchID]      INT            NULL,
    [ExtractDateTime] DATETIME2 (0)  NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Customers]...';


GO
CREATE TABLE [stg].[Customers] (
    [CustomerID]      NCHAR (5)     NOT NULL,
    [CompanyName]     NVARCHAR (40) NOT NULL,
    [ContactName]     NVARCHAR (30) NULL,
    [ContactTitle]    NVARCHAR (30) NULL,
    [Address]         NVARCHAR (60) NULL,
    [City]            NVARCHAR (15) NULL,
    [Region]          NVARCHAR (15) NULL,
    [PostalCode]      NVARCHAR (10) NULL,
    [Country]         NVARCHAR (15) NULL,
    [Phone]           NVARCHAR (24) NULL,
    [Fax]             NVARCHAR (24) NULL,
    [ETLBatchID]      INT           NULL,
    [ExtractDateTime] DATETIME2 (0) NOT NULL
);


GO
PRINT N'Creando Tabla [stg].[Categories]...';


GO
CREATE TABLE [stg].[Categories] (
    [CategoryID]      INT            NOT NULL,
    [CategoryName]    NVARCHAR (15)  NOT NULL,
    [Description]     NVARCHAR (MAX) NULL,
    [ETLBatchID]      INT            NULL,
    [ExtractDateTime] DATETIME2 (0)  NOT NULL
);


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_ReqDate]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_ReqDate] DEFAULT (-1) FOR [RequiredDateKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_ShipDate]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_ShipDate] DEFAULT (-1) FOR [ShippedDateKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Cust]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Cust] DEFAULT (-1) FOR [CustomerKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Prod]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Prod] DEFAULT (-1) FOR [ProductKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Emp]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Emp] DEFAULT (-1) FOR [EmployeeKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Shipper]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Shipper] DEFAULT (-1) FOR [ShipperKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Geo]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Geo] DEFAULT (-1) FOR [ShipGeographyKey];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Freight]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Freight] DEFAULT (0) FOR [FreightAllocated];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_FactSales_Load]...';


GO
ALTER TABLE [dw].[FactSales]
    ADD CONSTRAINT [DF_FactSales_Load] DEFAULT (SYSDATETIME()) FOR [LoadDateTime];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipper_Exp]...';


GO
ALTER TABLE [dw].[DimShipper]
    ADD CONSTRAINT [DF_DimShipper_Exp] DEFAULT ('9999-12-31') FOR [RowExpirationDate];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipper_Cur]...';


GO
ALTER TABLE [dw].[DimShipper]
    ADD CONSTRAINT [DF_DimShipper_Cur] DEFAULT (1) FOR [IsCurrent];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipper_Ins]...';


GO
ALTER TABLE [dw].[DimShipper]
    ADD CONSTRAINT [DF_DimShipper_Ins] DEFAULT (SYSDATETIME()) FOR [InsertedAt];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipGeo_Exp]...';


GO
ALTER TABLE [dw].[DimShipGeography]
    ADD CONSTRAINT [DF_DimShipGeo_Exp] DEFAULT ('9999-12-31') FOR [RowExpirationDate];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipGeo_Cur]...';


GO
ALTER TABLE [dw].[DimShipGeography]
    ADD CONSTRAINT [DF_DimShipGeo_Cur] DEFAULT (1) FOR [IsCurrent];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimShipGeo_Ins]...';


GO
ALTER TABLE [dw].[DimShipGeography]
    ADD CONSTRAINT [DF_DimShipGeo_Ins] DEFAULT (SYSDATETIME()) FOR [InsertedAt];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimProduct_Exp]...';


GO
ALTER TABLE [dw].[DimProduct]
    ADD CONSTRAINT [DF_DimProduct_Exp] DEFAULT ('9999-12-31') FOR [RowExpirationDate];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimProduct_Cur]...';


GO
ALTER TABLE [dw].[DimProduct]
    ADD CONSTRAINT [DF_DimProduct_Cur] DEFAULT (1) FOR [IsCurrent];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimProduct_Ins]...';


GO
ALTER TABLE [dw].[DimProduct]
    ADD CONSTRAINT [DF_DimProduct_Ins] DEFAULT (SYSDATETIME()) FOR [InsertedAt];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimEmployee_Exp]...';


GO
ALTER TABLE [dw].[DimEmployee]
    ADD CONSTRAINT [DF_DimEmployee_Exp] DEFAULT ('9999-12-31') FOR [RowExpirationDate];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimEmployee_Cur]...';


GO
ALTER TABLE [dw].[DimEmployee]
    ADD CONSTRAINT [DF_DimEmployee_Cur] DEFAULT (1) FOR [IsCurrent];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimEmployee_Ins]...';


GO
ALTER TABLE [dw].[DimEmployee]
    ADD CONSTRAINT [DF_DimEmployee_Ins] DEFAULT (SYSDATETIME()) FOR [InsertedAt];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimCustomer_Exp]...';


GO
ALTER TABLE [dw].[DimCustomer]
    ADD CONSTRAINT [DF_DimCustomer_Exp] DEFAULT ('9999-12-31') FOR [RowExpirationDate];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimCustomer_Cur]...';


GO
ALTER TABLE [dw].[DimCustomer]
    ADD CONSTRAINT [DF_DimCustomer_Cur] DEFAULT (1) FOR [IsCurrent];


GO
PRINT N'Creando Restricción DEFAULT [dw].[DF_DimCustomer_Ins]...';


GO
ALTER TABLE [dw].[DimCustomer]
    ADD CONSTRAINT [DF_DimCustomer_Ins] DEFAULT (SYSDATETIME()) FOR [InsertedAt];


GO
PRINT N'Creando Restricción DEFAULT [etl].[DF_LoadBatch_Start]...';


GO
ALTER TABLE [etl].[LoadBatch]
    ADD CONSTRAINT [DF_LoadBatch_Start] DEFAULT (SYSDATETIME()) FOR [StartTime];


GO
PRINT N'Creando Restricción DEFAULT [etl].[DF_LoadBatch_Status]...';


GO
ALTER TABLE [etl].[LoadBatch]
    ADD CONSTRAINT [DF_LoadBatch_Status] DEFAULT ('RUNNING') FOR [Status];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgSuppliers_Ext]...';


GO
ALTER TABLE [stg].[Suppliers]
    ADD CONSTRAINT [DF_stgSuppliers_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgShippers_Ext]...';


GO
ALTER TABLE [stg].[Shippers]
    ADD CONSTRAINT [DF_stgShippers_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgProducts_Ext]...';


GO
ALTER TABLE [stg].[Products]
    ADD CONSTRAINT [DF_stgProducts_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgOrders_Ext]...';


GO
ALTER TABLE [stg].[Orders]
    ADD CONSTRAINT [DF_stgOrders_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgOrderDetails_Ext]...';


GO
ALTER TABLE [stg].[OrderDetails]
    ADD CONSTRAINT [DF_stgOrderDetails_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgEmployees_Ext]...';


GO
ALTER TABLE [stg].[Employees]
    ADD CONSTRAINT [DF_stgEmployees_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgCustomers_Ext]...';


GO
ALTER TABLE [stg].[Customers]
    ADD CONSTRAINT [DF_stgCustomers_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Restricción DEFAULT [stg].[DF_stgCategories_Ext]...';


GO
ALTER TABLE [stg].[Categories]
    ADD CONSTRAINT [DF_stgCategories_Ext] DEFAULT (SYSDATETIME()) FOR [ExtractDateTime];


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_OrderDate]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_OrderDate] FOREIGN KEY ([OrderDateKey]) REFERENCES [dw].[DimDate] ([DateKey]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_RequiredDate]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_RequiredDate] FOREIGN KEY ([RequiredDateKey]) REFERENCES [dw].[DimDate] ([DateKey]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_ShippedDate]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_ShippedDate] FOREIGN KEY ([ShippedDateKey]) REFERENCES [dw].[DimDate] ([DateKey]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_Customer]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_Customer] FOREIGN KEY ([CustomerKey]) REFERENCES [dw].[DimCustomer] ([CustomerSK]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_Product]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_Product] FOREIGN KEY ([ProductKey]) REFERENCES [dw].[DimProduct] ([ProductSK]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_Employee]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_Employee] FOREIGN KEY ([EmployeeKey]) REFERENCES [dw].[DimEmployee] ([EmployeeSK]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_Shipper]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_Shipper] FOREIGN KEY ([ShipperKey]) REFERENCES [dw].[DimShipper] ([ShipperSK]);


GO
PRINT N'Creando Clave externa [dw].[FK_FactSales_ShipGeo]...';


GO
ALTER TABLE [dw].[FactSales] WITH NOCHECK
    ADD CONSTRAINT [FK_FactSales_ShipGeo] FOREIGN KEY ([ShipGeographyKey]) REFERENCES [dw].[DimShipGeography] ([ShipGeographySK]);


GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_OrderDate];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_RequiredDate];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_ShippedDate];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_Customer];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_Product];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_Employee];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_Shipper];

ALTER TABLE [dw].[FactSales] WITH CHECK CHECK CONSTRAINT [FK_FactSales_ShipGeo];


GO
PRINT N'Actualización completada.';


GO
