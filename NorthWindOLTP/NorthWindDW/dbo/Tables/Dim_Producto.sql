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

