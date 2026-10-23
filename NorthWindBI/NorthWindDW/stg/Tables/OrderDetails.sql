CREATE TABLE stg.OrderDetails(
    OrderID int NOT NULL, ProductID int NOT NULL, UnitPrice money NOT NULL,
    Quantity smallint NOT NULL, Discount real NOT NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgOrderDetails_Ext DEFAULT (SYSDATETIME())
);
