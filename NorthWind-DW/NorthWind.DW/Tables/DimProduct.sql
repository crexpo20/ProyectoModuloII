-- Dimension Producto desnormalizada: Products + Categories + Suppliers
CREATE TABLE [dw].[DimProduct] (
    [ProductKey]          INT IDENTITY(1,1) NOT NULL,
    [ProductID]           INT           NOT NULL,   -- llave de negocio
    [ProductName]         NVARCHAR(40)  NOT NULL,
    [QuantityPerUnit]     NVARCHAR(20)  NULL,
    [ListUnitPrice]       DECIMAL(19,4) NULL,
    [Discontinued]        BIT           NOT NULL,
    [CategoryID]          INT           NULL,
    [CategoryName]        NVARCHAR(15)  NOT NULL,
    [CategoryDescription] NVARCHAR(MAX) NULL,
    [SupplierID]          INT           NULL,
    [SupplierName]        NVARCHAR(40)  NOT NULL,
    [SupplierCity]        NVARCHAR(15)  NULL,
    [SupplierCountry]     NVARCHAR(15)  NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductKey]),
    CONSTRAINT [UQ_DimProduct_ProductID] UNIQUE ([ProductID])
);
