CREATE TABLE stg.Products(
    ProductID int NOT NULL, ProductName nvarchar(40) NOT NULL, SupplierID int NULL, CategoryID int NULL,
    QuantityPerUnit nvarchar(20) NULL, UnitPrice money NULL, UnitsInStock smallint NULL,
    UnitsOnOrder smallint NULL, ReorderLevel smallint NULL, Discontinued bit NOT NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgProducts_Ext DEFAULT (SYSDATETIME())
);
