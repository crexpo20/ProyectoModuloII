CREATE TABLE [dbo].[DimProducto]
(
    [ProductoKey] INT IDENTITY(1,1) NOT NULL,
    [ProductID] INT NOT NULL,
    [Producto] NVARCHAR(40) NOT NULL,
    [Categoria] NVARCHAR(15) NULL,
    [DescripcionCategoria] NVARCHAR(MAX) NULL,
    [Proveedor] NVARCHAR(40) NULL,
    [CantidadPorUnidad] NVARCHAR(20) NULL,
    [PrecioActual] DECIMAL(19,4) NULL,
    [UnidadesEnStock] SMALLINT NULL,
    [UnidadesEnPedido] SMALLINT NULL,
    [NivelReposicion] SMALLINT NULL,
    [Descontinuado] BIT NOT NULL,
    CONSTRAINT [PK_DimProducto] PRIMARY KEY CLUSTERED ([ProductoKey]),
    CONSTRAINT [UQ_DimProducto_ProductID] UNIQUE ([ProductID])
);
