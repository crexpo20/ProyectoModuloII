CREATE TABLE stg.Shippers(
    ShipperID int NOT NULL, CompanyName nvarchar(40) NOT NULL, Phone nvarchar(24) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgShippers_Ext DEFAULT (SYSDATETIME())
);
