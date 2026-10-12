/* ==========================================================
   04_create_staging.sql
   Área de staging: copia cruda (1:1) de las tablas OLTP necesarias.
   - Heaps sin PK/FK/índices -> carga masiva rápida (TRUNCATE + INSERT por lote)
   - Se excluyen columnas BLOB (Photo, Picture) y Notes: no aportan al análisis
   - [rowversion] del origen no se copia (timestamp no es insertable);
     el delta se detecta por RowHash en las dimensiones
   - Columnas de control: ETLBatchID, ExtractDateTime
   ========================================================== */
USE [prueba];
GO

/* ---------- Control de lotes ---------- */
CREATE TABLE etl.LoadBatch(
    ETLBatchID     int IDENTITY(1,1) NOT NULL,
    StartTime      datetime2(0)  NOT NULL CONSTRAINT DF_LoadBatch_Start DEFAULT (SYSDATETIME()),
    EndTime        datetime2(0)  NULL,
    Status         varchar(15)   NOT NULL CONSTRAINT DF_LoadBatch_Status DEFAULT ('RUNNING'), -- RUNNING / SUCCESS / FAILED
    RowsExtracted  int           NULL,
    ErrorMessage   nvarchar(4000) NULL,
    CONSTRAINT PK_LoadBatch PRIMARY KEY CLUSTERED (ETLBatchID)
);
GO

/* ---------- stg.Customers ---------- */
CREATE TABLE stg.Customers(
    CustomerID nchar(5) NOT NULL, CompanyName nvarchar(40) NOT NULL, ContactName nvarchar(30) NULL,
    ContactTitle nvarchar(30) NULL, Address nvarchar(60) NULL, City nvarchar(15) NULL, Region nvarchar(15) NULL,
    PostalCode nvarchar(10) NULL, Country nvarchar(15) NULL, Phone nvarchar(24) NULL, Fax nvarchar(24) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgCustomers_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Suppliers ---------- */
CREATE TABLE stg.Suppliers(
    SupplierID int NOT NULL, CompanyName nvarchar(40) NOT NULL, ContactName nvarchar(30) NULL,
    ContactTitle nvarchar(30) NULL, Address nvarchar(60) NULL, City nvarchar(15) NULL, Region nvarchar(15) NULL,
    PostalCode nvarchar(10) NULL, Country nvarchar(15) NULL, Phone nvarchar(24) NULL, Fax nvarchar(24) NULL,
    HomePage nvarchar(max) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgSuppliers_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Categories ---------- */
CREATE TABLE stg.Categories(
    CategoryID int NOT NULL, CategoryName nvarchar(15) NOT NULL, Description nvarchar(max) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgCategories_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Products ---------- */
CREATE TABLE stg.Products(
    ProductID int NOT NULL, ProductName nvarchar(40) NOT NULL, SupplierID int NULL, CategoryID int NULL,
    QuantityPerUnit nvarchar(20) NULL, UnitPrice money NULL, UnitsInStock smallint NULL,
    UnitsOnOrder smallint NULL, ReorderLevel smallint NULL, Discontinued bit NOT NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgProducts_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Employees ---------- */
CREATE TABLE stg.Employees(
    EmployeeID int NOT NULL, LastName nvarchar(20) NOT NULL, FirstName nvarchar(10) NOT NULL,
    Title nvarchar(30) NULL, TitleOfCourtesy nvarchar(25) NULL, BirthDate datetime NULL, HireDate datetime NULL,
    Address nvarchar(60) NULL, City nvarchar(15) NULL, Region nvarchar(15) NULL, PostalCode nvarchar(10) NULL,
    Country nvarchar(15) NULL, HomePhone nvarchar(24) NULL, Extension nvarchar(4) NULL,
    ReportsTo int NULL, PhotoPath nvarchar(255) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgEmployees_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Shippers ---------- */
CREATE TABLE stg.Shippers(
    ShipperID int NOT NULL, CompanyName nvarchar(40) NOT NULL, Phone nvarchar(24) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgShippers_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.Orders ---------- */
CREATE TABLE stg.Orders(
    OrderID int NOT NULL, CustomerID nchar(5) NULL, EmployeeID int NULL, OrderDate datetime NULL,
    RequiredDate datetime NULL, ShippedDate datetime NULL, ShipVia int NULL, Freight money NULL,
    ShipName nvarchar(40) NULL, ShipAddress nvarchar(60) NULL, ShipCity nvarchar(15) NULL,
    ShipRegion nvarchar(15) NULL, ShipPostalCode nvarchar(10) NULL, ShipCountry nvarchar(15) NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgOrders_Ext DEFAULT (SYSDATETIME())
);
GO

/* ---------- stg.OrderDetails ---------- */
CREATE TABLE stg.OrderDetails(
    OrderID int NOT NULL, ProductID int NOT NULL, UnitPrice money NOT NULL,
    Quantity smallint NOT NULL, Discount real NOT NULL,
    ETLBatchID int NULL, ExtractDateTime datetime2(0) NOT NULL CONSTRAINT DF_stgOrderDetails_Ext DEFAULT (SYSDATETIME())
);
GO