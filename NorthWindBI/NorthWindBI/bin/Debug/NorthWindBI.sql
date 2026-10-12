/*
Script de implementación para NorthWindBI

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "NorthWindBI"
:setvar DefaultFilePrefix "NorthWindBI"
:setvar DefaultDataPath "C:\Users\Mauricio\AppData\Local\Microsoft\VisualStudio\SSDT\NorthWindBI"
:setvar DefaultLogPath "C:\Users\Mauricio\AppData\Local\Microsoft\VisualStudio\SSDT\NorthWindBI"

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
PRINT N'Creando Tabla [dbo].[CustomerCustomerDemo]...';


GO
CREATE TABLE [dbo].[CustomerCustomerDemo] (
    [CustomerID]     NCHAR (5)  NOT NULL,
    [CustomerTypeID] NCHAR (10) NOT NULL,
    [rowversion]     TIMESTAMP  NULL,
    CONSTRAINT [PK_CustomerCustomerDemo] PRIMARY KEY NONCLUSTERED ([CustomerID] ASC, [CustomerTypeID] ASC)
) ON [PRIMARY];


GO
PRINT N'Creando Tabla [dbo].[CustomerDemographics]...';


GO
CREATE TABLE [dbo].[CustomerDemographics] (
    [CustomerTypeID] NCHAR (10)     NOT NULL,
    [CustomerDesc]   NVARCHAR (MAX) NULL,
    [rowversion]     TIMESTAMP      NULL,
    CONSTRAINT [PK_CustomerDemographics] PRIMARY KEY NONCLUSTERED ([CustomerTypeID] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


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
) ON [PRIMARY];


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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
PRINT N'Creando Tabla [dbo].[EmployeeTerritories]...';


GO
CREATE TABLE [dbo].[EmployeeTerritories] (
    [EmployeeID]  INT           NOT NULL,
    [TerritoryID] NVARCHAR (20) NOT NULL,
    [rowversion]  TIMESTAMP     NULL,
    CONSTRAINT [PK_EmployeeTerritories] PRIMARY KEY NONCLUSTERED ([EmployeeID] ASC, [TerritoryID] ASC)
) ON [PRIMARY];


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
) ON [PRIMARY];


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
) ON [PRIMARY];


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
) ON [PRIMARY];


GO
PRINT N'Creando Tabla [dbo].[Region]...';


GO
CREATE TABLE [dbo].[Region] (
    [RegionID]          INT        NOT NULL,
    [RegionDescription] NCHAR (50) NOT NULL,
    [rowversion]        TIMESTAMP  NULL,
    CONSTRAINT [PK_Region] PRIMARY KEY NONCLUSTERED ([RegionID] ASC)
) ON [PRIMARY];


GO
PRINT N'Creando Tabla [dbo].[Shippers]...';


GO
CREATE TABLE [dbo].[Shippers] (
    [ShipperID]   INT           IDENTITY (1, 1) NOT NULL,
    [CompanyName] NVARCHAR (40) NOT NULL,
    [Phone]       NVARCHAR (24) NULL,
    [rowversion]  TIMESTAMP     NULL,
    CONSTRAINT [PK_Shippers] PRIMARY KEY CLUSTERED ([ShipperID] ASC)
) ON [PRIMARY];


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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
PRINT N'Creando Tabla [dbo].[Territories]...';


GO
CREATE TABLE [dbo].[Territories] (
    [TerritoryID]          NVARCHAR (20) NOT NULL,
    [TerritoryDescription] NCHAR (50)    NOT NULL,
    [RegionID]             INT           NOT NULL,
    [rowversion]           TIMESTAMP     NULL,
    CONSTRAINT [PK_Territories] PRIMARY KEY NONCLUSTERED ([TerritoryID] ASC)
) ON [PRIMARY];


GO
PRINT N'Actualización completada.';


GO
