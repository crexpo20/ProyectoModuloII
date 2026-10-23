CREATE TABLE dw.DimProduct(
    ProductSK            int IDENTITY(1,1) NOT NULL,
    ProductID            int            NOT NULL,   -- business key
    ProductName          nvarchar(40)   NOT NULL,
    QuantityPerUnit      nvarchar(20)   NULL,
    ListPrice            decimal(19,4)  NULL,       -- precio de lista vigente (no el cobrado)
    ReorderLevel         smallint       NULL,
    IsDiscontinued       bit            NOT NULL,
    -- Categoría (desnormalizada)
    CategoryID           int            NULL,
    CategoryName         nvarchar(15)   NULL,
    CategoryDescription  nvarchar(500)  NULL,
    -- Proveedor (desnormalizado)
    SupplierID           int            NULL,
    SupplierName         nvarchar(40)   NULL,
    SupplierContactName  nvarchar(30)   NULL,
    SupplierContactTitle nvarchar(30)   NULL,
    SupplierAddress      nvarchar(60)   NULL,
    SupplierCity         nvarchar(15)   NULL,
    SupplierRegion       nvarchar(15)   NULL,
    SupplierPostalCode   nvarchar(10)   NULL,
    SupplierCountry      nvarchar(15)   NULL,
    SupplierPhone        nvarchar(24)   NULL,
    SupplierHomePage     nvarchar(400)  NULL,
    -- Control SCD2
    RowEffectiveDate     date           NOT NULL,
    RowExpirationDate    date           NOT NULL CONSTRAINT DF_DimProduct_Exp DEFAULT ('9999-12-31'),
    IsCurrent            bit            NOT NULL CONSTRAINT DF_DimProduct_Cur DEFAULT (1),
    RowHash              varbinary(32)  NULL,
    ETLBatchID           int            NULL,
    InsertedAt           datetime2(0)   NOT NULL CONSTRAINT DF_DimProduct_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimProduct PRIMARY KEY CLUSTERED (ProductSK)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimProduct_BK_Current ON dw.DimProduct (ProductID) WHERE IsCurrent = 1;
GO

CREATE NONCLUSTERED INDEX IX_DimProduct_BK_Dates ON dw.DimProduct (ProductID, RowEffectiveDate, RowExpirationDate);
