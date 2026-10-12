CREATE TABLE stg.Orders(
    OrderID int NOT NULL, CustomerID nchar(5) NULL, EmployeeID int NULL, OrderDate datetime NULL,
    RequiredDate datetime NULL, ShippedDate datetime NULL, ShipVia int NULL, Freight money NULL,
    ShipName nvarchar(40) NULL, ShipAddress nvarchar(60) NULL, ShipCity nvarchar(15) NULL,
    ShipRegion nvarchar(15) NULL, ShipPostalCode nvarchar(10) NULL, ShipCountry nvarchar(15) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgOrders_Ext DEFAULT (SYSDATETIME())
);
