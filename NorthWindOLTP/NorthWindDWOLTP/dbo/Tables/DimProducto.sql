CREATE TABLE [dbo].[DimProducto] (
    [ProductoKey]          INT             IDENTITY (1, 1) NOT NULL,
    [ProductoID]           INT             NOT NULL,
    [NombreProducto]       NVARCHAR (40)   NOT NULL,
    [NombreCategoria]      NVARCHAR (15)   NOT NULL,
    [DescripcionCategoria] NVARCHAR (MAX)  NULL,
    [NombreProveedor]      NVARCHAR (40)   NOT NULL,
    [PrecioUnitario]       DECIMAL (18, 2) NULL,
    [Descontinuado]        BIT             NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductoKey] ASC)
);

