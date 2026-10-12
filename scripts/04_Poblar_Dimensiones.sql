USE NorthWindDW;
GO

-- Llenar DimCustomer
INSERT INTO dbo.DimCustomer (CustomerID, CompanyName, ContactName, City, Country)
SELECT CustomerID, CompanyName, ContactName, City, Country 
FROM Northwind.dbo.Customers;

-- Llenar DimProduct
INSERT INTO dbo.DimProduct (ProductID, ProductName, CategoryName, SupplierName, UnitPrice)
SELECT p.ProductID, p.ProductName, c.CategoryName, s.CompanyName, p.UnitPrice
FROM Northwind.dbo.Products p
JOIN Northwind.dbo.Categories c ON p.CategoryID = c.CategoryID
JOIN Northwind.dbo.Suppliers s ON p.SupplierID = s.SupplierID;