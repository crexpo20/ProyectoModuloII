/*
Script de implementación para NorthWindOLTP

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "NorthWindOLTP"
:setvar DefaultFilePrefix "NorthWindOLTP"
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
PRINT N'Creando Tabla [dbo].[Categories]...';


GO
CREATE TABLE [dbo].[Categories] (
    [CategoryID]   INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName] NVARCHAR (15)  NOT NULL,
    [Description]  NVARCHAR (MAX) NULL,
    [Picture]      IMAGE          NULL,
    [rowversion]   TIMESTAMP      NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[CustomerCustomerDemo]...';


GO
CREATE TABLE [dbo].[CustomerCustomerDemo] (
    [CustomerID]     NCHAR (5)  NOT NULL,
    [CustomerTypeID] NCHAR (10) NOT NULL,
    [rowversion]     TIMESTAMP  NULL,
    CONSTRAINT [PK_CustomerCustomerDemo] PRIMARY KEY NONCLUSTERED ([CustomerID] ASC, [CustomerTypeID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[CustomerDemographics]...';


GO
CREATE TABLE [dbo].[CustomerDemographics] (
    [CustomerTypeID] NCHAR (10)     NOT NULL,
    [CustomerDesc]   NVARCHAR (MAX) NULL,
    [rowversion]     TIMESTAMP      NULL,
    CONSTRAINT [PK_CustomerDemographics] PRIMARY KEY NONCLUSTERED ([CustomerTypeID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Customers]...';


GO
CREATE TABLE [dbo].[Customers] (
    [CustomerID]   NCHAR (5)     NOT NULL,
    [CompanyName]  NVARCHAR (40) NOT NULL,
    [ContactName]  NVARCHAR (30) NULL,
    [ContactTitle] NVARCHAR (30) NULL,
    [Address]      NVARCHAR (60) NULL,
    [City]         NVARCHAR (15) NULL,
    [Region]       NVARCHAR (15) NULL,
    [PostalCode]   NVARCHAR (10) NULL,
    [Country]      NVARCHAR (15) NULL,
    [Phone]        NVARCHAR (24) NULL,
    [Fax]          NVARCHAR (24) NULL,
    [rowversion]   TIMESTAMP     NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Employees]...';


GO
CREATE TABLE [dbo].[Employees] (
    [EmployeeID]      INT            IDENTITY (1, 1) NOT NULL,
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
    [Photo]           IMAGE          NULL,
    [Notes]           NVARCHAR (MAX) NULL,
    [ReportsTo]       INT            NULL,
    [PhotoPath]       NVARCHAR (255) NULL,
    [rowversion]      TIMESTAMP      NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([EmployeeID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[EmployeeTerritories]...';


GO
CREATE TABLE [dbo].[EmployeeTerritories] (
    [EmployeeID]  INT           NOT NULL,
    [TerritoryID] NVARCHAR (20) NOT NULL,
    [rowversion]  TIMESTAMP     NULL,
    CONSTRAINT [PK_EmployeeTerritories] PRIMARY KEY NONCLUSTERED ([EmployeeID] ASC, [TerritoryID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[OrderDetails]...';


GO
CREATE TABLE [dbo].[OrderDetails] (
    [OrderID]    INT       NOT NULL,
    [ProductID]  INT       NOT NULL,
    [UnitPrice]  MONEY     NOT NULL,
    [Quantity]   SMALLINT  NOT NULL,
    [Discount]   REAL      NOT NULL,
    [rowversion] TIMESTAMP NULL,
    CONSTRAINT [PK_Order_Details] PRIMARY KEY CLUSTERED ([OrderID] ASC, [ProductID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Orders]...';


GO
CREATE TABLE [dbo].[Orders] (
    [OrderID]        INT           IDENTITY (1, 1) NOT NULL,
    [CustomerID]     NCHAR (5)     NULL,
    [EmployeeID]     INT           NULL,
    [OrderDate]      DATETIME      NULL,
    [RequiredDate]   DATETIME      NULL,
    [ShippedDate]    DATETIME      NULL,
    [ShipVia]        INT           NULL,
    [Freight]        MONEY         NULL,
    [ShipName]       NVARCHAR (40) NULL,
    [ShipAddress]    NVARCHAR (60) NULL,
    [ShipCity]       NVARCHAR (15) NULL,
    [ShipRegion]     NVARCHAR (15) NULL,
    [ShipPostalCode] NVARCHAR (10) NULL,
    [ShipCountry]    NVARCHAR (15) NULL,
    [rowversion]     TIMESTAMP     NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Products]...';


GO
CREATE TABLE [dbo].[Products] (
    [ProductID]       INT           IDENTITY (1, 1) NOT NULL,
    [ProductName]     NVARCHAR (40) NOT NULL,
    [SupplierID]      INT           NULL,
    [CategoryID]      INT           NULL,
    [QuantityPerUnit] NVARCHAR (20) NULL,
    [UnitPrice]       MONEY         NULL,
    [UnitsInStock]    SMALLINT      NULL,
    [UnitsOnOrder]    SMALLINT      NULL,
    [ReorderLevel]    SMALLINT      NULL,
    [Discontinued]    BIT           NOT NULL,
    [rowversion]      TIMESTAMP     NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([ProductID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Region]...';


GO
CREATE TABLE [dbo].[Region] (
    [RegionID]          INT        NOT NULL,
    [RegionDescription] NCHAR (50) NOT NULL,
    [rowversion]        TIMESTAMP  NULL,
    CONSTRAINT [PK_Region] PRIMARY KEY NONCLUSTERED ([RegionID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Shippers]...';


GO
CREATE TABLE [dbo].[Shippers] (
    [ShipperID]   INT           IDENTITY (1, 1) NOT NULL,
    [CompanyName] NVARCHAR (40) NOT NULL,
    [Phone]       NVARCHAR (24) NULL,
    [rowversion]  TIMESTAMP     NULL,
    CONSTRAINT [PK_Shippers] PRIMARY KEY CLUSTERED ([ShipperID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Suppliers]...';


GO
CREATE TABLE [dbo].[Suppliers] (
    [SupplierID]   INT            IDENTITY (1, 1) NOT NULL,
    [CompanyName]  NVARCHAR (40)  NOT NULL,
    [ContactName]  NVARCHAR (30)  NULL,
    [ContactTitle] NVARCHAR (30)  NULL,
    [Address]      NVARCHAR (60)  NULL,
    [City]         NVARCHAR (15)  NULL,
    [Region]       NVARCHAR (15)  NULL,
    [PostalCode]   NVARCHAR (10)  NULL,
    [Country]      NVARCHAR (15)  NULL,
    [Phone]        NVARCHAR (24)  NULL,
    [Fax]          NVARCHAR (24)  NULL,
    [HomePage]     NVARCHAR (MAX) NULL,
    [rowversion]   TIMESTAMP      NULL,
    CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED ([SupplierID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Territories]...';


GO
CREATE TABLE [dbo].[Territories] (
    [TerritoryID]          NVARCHAR (20) NOT NULL,
    [TerritoryDescription] NCHAR (50)    NOT NULL,
    [RegionID]             INT           NOT NULL,
    [rowversion]           TIMESTAMP     NULL,
    CONSTRAINT [PK_Territories] PRIMARY KEY NONCLUSTERED ([TerritoryID] ASC)
);


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_UnitPrice]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_UnitPrice] DEFAULT ((0)) FOR [UnitPrice];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_Quantity]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_Quantity] DEFAULT ((1)) FOR [Quantity];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_Discount]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_Discount] DEFAULT ((0)) FOR [Discount];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Orders_Freight]...';


GO
ALTER TABLE [dbo].[Orders]
    ADD CONSTRAINT [DF_Orders_Freight] DEFAULT ((0)) FOR [Freight];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitPrice]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitPrice] DEFAULT ((0)) FOR [UnitPrice];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitsInStock]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitsInStock] DEFAULT ((0)) FOR [UnitsInStock];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitsOnOrder]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitsOnOrder] DEFAULT ((0)) FOR [UnitsOnOrder];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_ReorderLevel]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_ReorderLevel] DEFAULT ((0)) FOR [ReorderLevel];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_Discontinued]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_Discontinued] DEFAULT ((0)) FOR [Discontinued];


GO
PRINT N'Creando Clave externa [dbo].[FK_CustomerCustomerDemo]...';


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH NOCHECK
    ADD CONSTRAINT [FK_CustomerCustomerDemo] FOREIGN KEY ([CustomerTypeID]) REFERENCES [dbo].[CustomerDemographics] ([CustomerTypeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_CustomerCustomerDemo_Customers]...';


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH NOCHECK
    ADD CONSTRAINT [FK_CustomerCustomerDemo_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Employees_Employees]...';


GO
ALTER TABLE [dbo].[Employees] WITH NOCHECK
    ADD CONSTRAINT [FK_Employees_Employees] FOREIGN KEY ([ReportsTo]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_EmployeeTerritories_Employees]...';


GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH NOCHECK
    ADD CONSTRAINT [FK_EmployeeTerritories_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_EmployeeTerritories_Territories]...';


GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH NOCHECK
    ADD CONSTRAINT [FK_EmployeeTerritories_Territories] FOREIGN KEY ([TerritoryID]) REFERENCES [dbo].[Territories] ([TerritoryID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Order_Details_Orders]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_Order_Details_Orders] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Order_Details_Products]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_Order_Details_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Customers]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Employees]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Shippers]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY ([ShipVia]) REFERENCES [dbo].[Shippers] ([ShipperID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Products_Categories]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Products_Suppliers]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [FK_Products_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Territories_Region]...';


GO
ALTER TABLE [dbo].[Territories] WITH NOCHECK
    ADD CONSTRAINT [FK_Territories_Region] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Region] ([RegionID]);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Birthdate]...';


GO
ALTER TABLE [dbo].[Employees] WITH NOCHECK
    ADD CONSTRAINT [CK_Birthdate] CHECK (([BirthDate]<getdate()));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Discount]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_Discount] CHECK (([Discount]>=(0) AND [Discount]<=(1)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Quantity]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_Quantity] CHECK (([Quantity]>(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitPrice]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitPrice] CHECK (([UnitPrice]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Products_UnitPrice]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_Products_UnitPrice] CHECK (([UnitPrice]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_ReorderLevel]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_ReorderLevel] CHECK (([ReorderLevel]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitsInStock]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitsInStock] CHECK (([UnitsInStock]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitsOnOrder]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitsOnOrder] CHECK (([UnitsOnOrder]>=(0)));


GO
PRINT N'Creando Procedimiento [dbo].[GetCustomerChangesByRowVersion]...';


GO
CREATE PROCEDURE [dbo].[GetCustomerChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
  SELECT 
     c.[CustomerID]
    ,c.[CompanyName]
    ,c.[ContactName]
    ,c.[ContactTitle]
    ,c.[Address]
    ,c.[City]
    ,c.[Region]
    ,c.[PostalCode]
    ,c.[Country]
    ,c.[Phone]
    ,c.[Fax]
    ,c.[rowversion]
    ,g.[CustomerDesc]
  FROM [dbo].[Customers] c
  LEFT JOIN [dbo].[CustomerCustomerDemo] d ON c.CustomerID = d.CustomerID
  LEFT JOIN [dbo].[CustomerDemographics] g ON d.CustomerTypeID = g.CustomerTypeID
  WHERE (CAST(c.[rowversion] AS BIGINT) > @startRow AND CAST(c.[rowversion] AS BIGINT) <= @endRow)
     OR (CAST(d.[rowversion] AS BIGINT) > @startRow AND CAST(d.[rowversion] AS BIGINT) <= @endRow)
     OR (CAST(g.[rowversion] AS BIGINT) > @startRow AND CAST(g.[rowversion] AS BIGINT) <= @endRow);
END
GO
PRINT N'Creando Procedimiento [dbo].[GetDatabaseRowVersion]...';


GO
CREATE PROCEDURE [dbo].[GetDatabaseRowVersion]
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    SELECT DBTS = (CONVERT(BIGINT, MIN_ACTIVE_ROWVERSION()) - 1);
END
GO
PRINT N'Creando Procedimiento [dbo].[GetEmployeeChangesByRowVersion]...';


GO
CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
       e.[EmployeeID]
      ,e.[LastName]
      ,e.[FirstName]
      ,e.[Title]
      ,e.[TitleOfCourtesy]
      ,e.[BirthDate]
      ,e.[HireDate]
      ,e.[Address]
      ,e.[City]
      ,e.[Region]
      ,e.[PostalCode]
      ,e.[Country]
      ,e.[HomePhone]
      ,e.[Extension]
      ,e.[Photo]
      ,e.[Notes]
      ,e.[ReportsTo]
      ,e.[PhotoPath]
      ,t.[TerritoryDescription]
      ,r.[RegionDescription]
    FROM [dbo].[Employees] e
    INNER JOIN [dbo].[EmployeeTerritories] et ON e.EmployeeID = et.EmployeeID
    INNER JOIN [dbo].[Territories] t ON et.TerritoryID = t.TerritoryID
    INNER JOIN [dbo].[Region] r ON t.RegionID = r.RegionID
    WHERE (CAST(e.[rowversion] AS BIGINT) > @startRow AND CAST(e.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(et.[rowversion] AS BIGINT) > @startRow AND CAST(et.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(t.[rowversion] AS BIGINT) > @startRow AND CAST(t.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(r.[rowversion] AS BIGINT) > @startRow AND CAST(r.[rowversion] AS BIGINT) <= @endRow);
END
GO
PRINT N'Creando Procedimiento [dbo].[GetProductChangesByRowVersion]...';


GO
CREATE PROCEDURE [dbo].[GetProductChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
       p.[ProductID]
      ,p.[ProductName]
      ,s.[CompanyName]
      ,c.[CategoryName]
      ,p.[QuantityPerUnit]
      ,p.[UnitPrice]
      ,p.[UnitsInStock]
      ,p.[UnitsOnOrder]
      ,p.[ReorderLevel]
      ,p.[Discontinued]
    FROM [dbo].[Products] p
    INNER JOIN [dbo].[Categories] c ON p.CategoryID = c.CategoryID
    INNER JOIN [dbo].[Suppliers] s ON p.SupplierID = s.SupplierID
    WHERE (CAST(p.[rowversion] AS BIGINT) > @startRow AND CAST(p.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(c.[rowversion] AS BIGINT) > @startRow AND CAST(c.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(s.[rowversion] AS BIGINT) > @startRow AND CAST(s.[rowversion] AS BIGINT) <= @endRow);
END
GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK CHECK CONSTRAINT [FK_CustomerCustomerDemo];

ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK CHECK CONSTRAINT [FK_CustomerCustomerDemo_Customers];

ALTER TABLE [dbo].[Employees] WITH CHECK CHECK CONSTRAINT [FK_Employees_Employees];

ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK CHECK CONSTRAINT [FK_EmployeeTerritories_Employees];

ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK CHECK CONSTRAINT [FK_EmployeeTerritories_Territories];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [FK_Order_Details_Orders];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [FK_Order_Details_Products];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Customers];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Employees];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Shippers];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [FK_Products_Categories];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [FK_Products_Suppliers];

ALTER TABLE [dbo].[Territories] WITH CHECK CHECK CONSTRAINT [FK_Territories_Region];

ALTER TABLE [dbo].[Employees] WITH CHECK CHECK CONSTRAINT [CK_Birthdate];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_Discount];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_Quantity];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_UnitPrice];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_Products_UnitPrice];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_ReorderLevel];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_UnitsInStock];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_UnitsOnOrder];


GO
PRINT N'Actualización completada.';


GO
