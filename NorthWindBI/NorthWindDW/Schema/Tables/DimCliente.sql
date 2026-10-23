CREATE TABLE [dbo].[DimCliente]
(
    [ClienteKey] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] NCHAR(5) NOT NULL,
    [Empresa] NVARCHAR(40) NOT NULL,
    [Contacto] NVARCHAR(30) NULL,
    [CargoContacto] NVARCHAR(30) NULL,
    [Ciudad] NVARCHAR(15) NULL,
    [Region] NVARCHAR(15) NULL,
    [CodigoPostal] NVARCHAR(10) NULL,
    [Pais] NVARCHAR(15) NULL,
    CONSTRAINT [PK_DimCliente] PRIMARY KEY CLUSTERED ([ClienteKey]),
    CONSTRAINT [UQ_DimCliente_CustomerID] UNIQUE ([CustomerID])
);
