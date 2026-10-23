/*
Script de implementación para NorthWindDW

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "NorthWindDW"
:setvar DefaultFilePrefix "NorthWindDW"
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
PRINT N'Creando Tabla [dbo].[DimCliente]...';


GO
CREATE TABLE [dbo].[DimCliente] (
    [ClienteKey]    INT           IDENTITY (1, 1) NOT NULL,
    [CustomerID]    NCHAR (5)     NOT NULL,
    [Empresa]       NVARCHAR (40) NOT NULL,
    [Contacto]      NVARCHAR (30) NULL,
    [CargoContacto] NVARCHAR (30) NULL,
    [Ciudad]        NVARCHAR (15) NULL,
    [Region]        NVARCHAR (15) NULL,
    [CodigoPostal]  NVARCHAR (10) NULL,
    [Pais]          NVARCHAR (15) NULL,
    CONSTRAINT [PK_DimCliente] PRIMARY KEY CLUSTERED ([ClienteKey] ASC),
    CONSTRAINT [UQ_DimCliente_CustomerID] UNIQUE NONCLUSTERED ([CustomerID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimEmpleado]...';


GO
CREATE TABLE [dbo].[DimEmpleado] (
    [EmpleadoKey]       INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeID]        INT           NOT NULL,
    [Nombre]            NVARCHAR (10) NOT NULL,
    [Apellido]          NVARCHAR (20) NOT NULL,
    [Cargo]             NVARCHAR (30) NULL,
    [Ciudad]            NVARCHAR (15) NULL,
    [Region]            NVARCHAR (15) NULL,
    [CodigoPostal]      NVARCHAR (10) NULL,
    [Pais]              NVARCHAR (15) NULL,
    [FechaContratacion] DATE          NULL,
    CONSTRAINT [PK_DimEmpleado] PRIMARY KEY CLUSTERED ([EmpleadoKey] ASC),
    CONSTRAINT [UQ_DimEmpleado_EmployeeID] UNIQUE NONCLUSTERED ([EmployeeID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimFecha]...';


GO
CREATE TABLE [dbo].[DimFecha] (
    [FechaKey]      INT           NOT NULL,
    [Fecha]         DATE          NOT NULL,
    [Dia]           TINYINT       NOT NULL,
    [Mes]           TINYINT       NOT NULL,
    [NombreMes]     NVARCHAR (15) NOT NULL,
    [Trimestre]     TINYINT       NOT NULL,
    [Anio]          SMALLINT      NOT NULL,
    [DiaSemana]     TINYINT       NOT NULL,
    [NombreDia]     NVARCHAR (15) NOT NULL,
    [EsFinDeSemana] BIT           NOT NULL,
    CONSTRAINT [PK_DimFecha] PRIMARY KEY CLUSTERED ([FechaKey] ASC),
    CONSTRAINT [UQ_DimFecha_Fecha] UNIQUE NONCLUSTERED ([Fecha] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimProducto]...';


GO
CREATE TABLE [dbo].[DimProducto] (
    [ProductoKey]          INT             IDENTITY (1, 1) NOT NULL,
    [ProductID]            INT             NOT NULL,
    [Producto]             NVARCHAR (40)   NOT NULL,
    [Categoria]            NVARCHAR (15)   NULL,
    [DescripcionCategoria] NVARCHAR (MAX)  NULL,
    [Proveedor]            NVARCHAR (40)   NULL,
    [CantidadPorUnidad]    NVARCHAR (20)   NULL,
    [PrecioActual]         DECIMAL (19, 4) NULL,
    [UnidadesEnStock]      SMALLINT        NULL,
    [UnidadesEnPedido]     SMALLINT        NULL,
    [NivelReposicion]      SMALLINT        NULL,
    [Descontinuado]        BIT             NOT NULL,
    CONSTRAINT [PK_DimProducto] PRIMARY KEY CLUSTERED ([ProductoKey] ASC),
    CONSTRAINT [UQ_DimProducto_ProductID] UNIQUE NONCLUSTERED ([ProductID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimTransportista]...';


GO
CREATE TABLE [dbo].[DimTransportista] (
    [TransportistaKey] INT           IDENTITY (1, 1) NOT NULL,
    [ShipperID]        INT           NOT NULL,
    [Empresa]          NVARCHAR (40) NOT NULL,
    [Telefono]         NVARCHAR (24) NULL,
    CONSTRAINT [PK_DimTransportista] PRIMARY KEY CLUSTERED ([TransportistaKey] ASC),
    CONSTRAINT [UQ_DimTransportista_ShipperID] UNIQUE NONCLUSTERED ([ShipperID] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[FactVentas]...';


GO
CREATE TABLE [dbo].[FactVentas] (
    [VentaKey]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [OrderID]           INT             NOT NULL,
    [ProductID]         INT             NOT NULL,
    [FechaPedidoKey]    INT             NULL,
    [FechaRequeridaKey] INT             NULL,
    [FechaEnvioKey]     INT             NULL,
    [ClienteKey]        INT             NULL,
    [ProductoKey]       INT             NOT NULL,
    [EmpleadoKey]       INT             NULL,
    [TransportistaKey]  INT             NULL,
    [Cantidad]          SMALLINT        NOT NULL,
    [PrecioUnitario]    DECIMAL (19, 4) NOT NULL,
    [Descuento]         DECIMAL (9, 6)  NOT NULL,
    [ImporteBruto]      DECIMAL (19, 4) NOT NULL,
    [ImporteDescuento]  DECIMAL (19, 4) NOT NULL,
    [ImporteNeto]       DECIMAL (19, 4) NOT NULL,
    CONSTRAINT [PK_FactVentas] PRIMARY KEY CLUSTERED ([VentaKey] ASC),
    CONSTRAINT [UQ_FactVentas_PedidoProducto] UNIQUE NONCLUSTERED ([OrderID] ASC, [ProductID] ASC)
);


GO
PRINT N'Creando Índice [dbo].[FactVentas].[IX_FactVentas_FechaPedido]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactVentas_FechaPedido]
    ON [dbo].[FactVentas]([FechaPedidoKey] ASC);


GO
PRINT N'Creando Índice [dbo].[FactVentas].[IX_FactVentas_Cliente]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactVentas_Cliente]
    ON [dbo].[FactVentas]([ClienteKey] ASC);


GO
PRINT N'Creando Índice [dbo].[FactVentas].[IX_FactVentas_Producto]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactVentas_Producto]
    ON [dbo].[FactVentas]([ProductoKey] ASC);


GO
PRINT N'Creando Índice [dbo].[FactVentas].[IX_FactVentas_Empleado]...';


GO
CREATE NONCLUSTERED INDEX [IX_FactVentas_Empleado]
    ON [dbo].[FactVentas]([EmpleadoKey] ASC);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_FechaPedido]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_FechaPedido] FOREIGN KEY ([FechaPedidoKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_FechaRequerida]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_FechaRequerida] FOREIGN KEY ([FechaRequeridaKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_FechaEnvio]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_FechaEnvio] FOREIGN KEY ([FechaEnvioKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_Cliente]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_Cliente] FOREIGN KEY ([ClienteKey]) REFERENCES [dbo].[DimCliente] ([ClienteKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_Producto]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_Producto] FOREIGN KEY ([ProductoKey]) REFERENCES [dbo].[DimProducto] ([ProductoKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_Empleado]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_Empleado] FOREIGN KEY ([EmpleadoKey]) REFERENCES [dbo].[DimEmpleado] ([EmpleadoKey]);


GO
PRINT N'Creando Clave externa [dbo].[FK_FactVentas_Transportista]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [FK_FactVentas_Transportista] FOREIGN KEY ([TransportistaKey]) REFERENCES [dbo].[DimTransportista] ([TransportistaKey]);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_DimFecha_Dia]...';


GO
ALTER TABLE [dbo].[DimFecha] WITH NOCHECK
    ADD CONSTRAINT [CK_DimFecha_Dia] CHECK ([Dia] BETWEEN 1 AND 31);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_DimFecha_Mes]...';


GO
ALTER TABLE [dbo].[DimFecha] WITH NOCHECK
    ADD CONSTRAINT [CK_DimFecha_Mes] CHECK ([Mes] BETWEEN 1 AND 12);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_DimFecha_Trimestre]...';


GO
ALTER TABLE [dbo].[DimFecha] WITH NOCHECK
    ADD CONSTRAINT [CK_DimFecha_Trimestre] CHECK ([Trimestre] BETWEEN 1 AND 4);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_FactVentas_Cantidad]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [CK_FactVentas_Cantidad] CHECK ([Cantidad] > 0);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_FactVentas_Precio]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [CK_FactVentas_Precio] CHECK ([PrecioUnitario] >= 0);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_FactVentas_Descuento]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [CK_FactVentas_Descuento] CHECK ([Descuento] >= 0 AND [Descuento] <= 1);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_FactVentas_Importes]...';


GO
ALTER TABLE [dbo].[FactVentas] WITH NOCHECK
    ADD CONSTRAINT [CK_FactVentas_Importes] CHECK ([ImporteBruto] >= 0 AND [ImporteDescuento] >= 0 AND [ImporteNeto] >= 0);


GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_FechaPedido];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_FechaRequerida];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_FechaEnvio];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_Cliente];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_Producto];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_Empleado];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [FK_FactVentas_Transportista];

ALTER TABLE [dbo].[DimFecha] WITH CHECK CHECK CONSTRAINT [CK_DimFecha_Dia];

ALTER TABLE [dbo].[DimFecha] WITH CHECK CHECK CONSTRAINT [CK_DimFecha_Mes];

ALTER TABLE [dbo].[DimFecha] WITH CHECK CHECK CONSTRAINT [CK_DimFecha_Trimestre];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [CK_FactVentas_Cantidad];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [CK_FactVentas_Precio];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [CK_FactVentas_Descuento];

ALTER TABLE [dbo].[FactVentas] WITH CHECK CHECK CONSTRAINT [CK_FactVentas_Importes];


GO
PRINT N'Actualización completada.';


GO
