CREATE TABLE stg.Categories(
    CategoryID int NOT NULL, CategoryName nvarchar(15) NOT NULL, Description nvarchar(max) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgCategories_Ext DEFAULT (SYSDATETIME())
);
