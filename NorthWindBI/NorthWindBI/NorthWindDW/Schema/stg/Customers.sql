CREATE TABLE stg.Customers(
    CustomerID nchar(5) NOT NULL, CompanyName nvarchar(40) NOT NULL, ContactName nvarchar(30) NULL,
    ContactTitle nvarchar(30) NULL, Address nvarchar(60) NULL, City nvarchar(15) NULL, Region nvarchar(15) NULL,
    PostalCode nvarchar(10) NULL, Country nvarchar(15) NULL, Phone nvarchar(24) NULL, Fax nvarchar(24) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgCustomers_Ext DEFAULT (SYSDATETIME())
);
