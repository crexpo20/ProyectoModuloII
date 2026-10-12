CREATE TABLE stg.Employees(
    EmployeeID int NOT NULL, LastName nvarchar(20) NOT NULL, FirstName nvarchar(10) NOT NULL,
    Title nvarchar(30) NULL, TitleOfCourtesy nvarchar(25) NULL, BirthDate datetime NULL, HireDate datetime NULL,
    Address nvarchar(60) NULL, City nvarchar(15) NULL, Region nvarchar(15) NULL, PostalCode nvarchar(10) NULL,
    Country nvarchar(15) NULL, HomePhone nvarchar(24) NULL, Extension nvarchar(4) NULL,
    ReportsTo int NULL, PhotoPath nvarchar(255) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgEmployees_Ext DEFAULT (SYSDATETIME())
);
