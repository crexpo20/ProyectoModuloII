/*
Script de implementación para nuevo

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "nuevo"
:setvar DefaultFilePrefix "nuevo"
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
PRINT N'Creando Tabla [dbo].[Dim_Cliente]...';


GO
CREATE TABLE [dbo].[Dim_Cliente] (
    [SK_Cliente]   INT            IDENTITY (1, 1) NOT NULL,
    [CustomerID]   NCHAR (5)      NOT NULL,
    [CompanyName]  NVARCHAR (40)  NOT NULL,
    [ContactName]  NVARCHAR (30)  NULL,
    [City]         NVARCHAR (15)  NULL,
    [Region]       NVARCHAR (15)  NULL,
    [Country]      NVARCHAR (15)  NULL,
    [CustomerDesc] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Dim_Cliente] PRIMARY KEY CLUSTERED ([SK_Cliente] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Dim_Empleado]...';


GO
CREATE TABLE [dbo].[Dim_Empleado] (
    [SK_Empleado]          INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeID]           INT           NOT NULL,
    [NombreCompleto]       NVARCHAR (31) NOT NULL,
    [Title]                NVARCHAR (30) NULL,
    [City]                 NVARCHAR (15) NULL,
    [Country]              NVARCHAR (15) NULL,
    [TerritoryDescription] NVARCHAR (50) NULL,
    [RegionDescription]    NCHAR (50)    NULL,
    CONSTRAINT [PK_Dim_Empleado] PRIMARY KEY CLUSTERED ([SK_Empleado] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Dim_Producto]...';


GO
CREATE TABLE [dbo].[Dim_Producto] (
    [SK_Producto]         INT            IDENTITY (1, 1) NOT NULL,
    [ProductID]           INT            NOT NULL,
    [ProductName]         NVARCHAR (40)  NOT NULL,
    [CategoryName]        NVARCHAR (15)  NULL,
    [CategoryDescription] NVARCHAR (MAX) NULL,
    [SupplierName]        NVARCHAR (40)  NULL,
    [SupplierCountry]     NVARCHAR (15)  NULL,
    [Discontinued]        BIT            NOT NULL,
    CONSTRAINT [PK_Dim_Producto] PRIMARY KEY CLUSTERED ([SK_Producto] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Dim_Tiempo]...';


GO
CREATE TABLE [dbo].[Dim_Tiempo] (
    [SK_Tiempo]       INT           NOT NULL,
    [Fecha]           DATE          NOT NULL,
    [Anio]            INT           NOT NULL,
    [Trimestre]       INT           NOT NULL,
    [Mes]             INT           NOT NULL,
    [NombreMes]       NVARCHAR (20) NOT NULL,
    [Dia]             INT           NOT NULL,
    [DiaSemana]       INT           NOT NULL,
    [NombreDiaSemana] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Dim_Tiempo] PRIMARY KEY CLUSTERED ([SK_Tiempo] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Dim_Transportista]...';


GO
CREATE TABLE [dbo].[Dim_Transportista] (
    [SK_Transportista] INT           IDENTITY (1, 1) NOT NULL,
    [ShipperID]        INT           NOT NULL,
    [CompanyName]      NVARCHAR (40) NOT NULL,
    CONSTRAINT [PK_Dim_Transportista] PRIMARY KEY CLUSTERED ([SK_Transportista] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[Fact_Ventas]...';


GO
CREATE TABLE [dbo].[Fact_Ventas] (
    [OrderID]          INT      NOT NULL,
    [SK_Tiempo]        INT      NOT NULL,
    [SK_Cliente]       INT      NOT NULL,
    [SK_Producto]      INT      NOT NULL,
    [SK_Empleado]      INT      NOT NULL,
    [SK_Transportista] INT      NOT NULL,
    [Quantity]         SMALLINT NOT NULL,
    [UnitPrice]        MONEY    NOT NULL,
    [Discount]         REAL     NOT NULL,
    [ExtendedPrice]    MONEY    NOT NULL,
    [Freight]          MONEY    NULL,
    CONSTRAINT [PK_Fact_Ventas] PRIMARY KEY CLUSTERED ([OrderID] ASC, [SK_Producto] ASC)
);


GO
PRINT N'Creando Clave externa [dbo].[FK_Fact_Ventas_Dim_Tiempo]...';


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ventas_Dim_Tiempo] FOREIGN KEY ([SK_Tiempo]) REFERENCES [dbo].[Dim_Tiempo] ([SK_Tiempo]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Fact_Ventas_Dim_Cliente]...';


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ventas_Dim_Cliente] FOREIGN KEY ([SK_Cliente]) REFERENCES [dbo].[Dim_Cliente] ([SK_Cliente]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Fact_Ventas_Dim_Producto]...';


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ventas_Dim_Producto] FOREIGN KEY ([SK_Producto]) REFERENCES [dbo].[Dim_Producto] ([SK_Producto]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Fact_Ventas_Dim_Empleado]...';


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ventas_Dim_Empleado] FOREIGN KEY ([SK_Empleado]) REFERENCES [dbo].[Dim_Empleado] ([SK_Empleado]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Fact_Ventas_Dim_Transportista]...';


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH NOCHECK
    ADD CONSTRAINT [FK_Fact_Ventas_Dim_Transportista] FOREIGN KEY ([SK_Transportista]) REFERENCES [dbo].[Dim_Transportista] ([SK_Transportista]);


GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ventas_Dim_Tiempo];

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ventas_Dim_Cliente];

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ventas_Dim_Producto];

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ventas_Dim_Empleado];

ALTER TABLE [dbo].[Fact_Ventas] WITH CHECK CHECK CONSTRAINT [FK_Fact_Ventas_Dim_Transportista];


GO
PRINT N'Actualización completada.';


GO
