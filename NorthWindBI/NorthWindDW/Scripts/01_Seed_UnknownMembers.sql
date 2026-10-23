/* Miembros 'Desconocido' (SK = -1) de cada dimensión */
IF NOT EXISTS (SELECT 1 FROM dw.DimCustomer WHERE CustomerSK = -1)
BEGIN
    SET IDENTITY_INSERT dw.DimCustomer ON;
    INSERT dw.DimCustomer (CustomerSK, CustomerID, CompanyName, RowEffectiveDate)
    VALUES (-1, N'-1', N'Desconocido', '1900-01-01');
    SET IDENTITY_INSERT dw.DimCustomer OFF;
END
GO
IF NOT EXISTS (SELECT 1 FROM dw.DimProduct WHERE ProductSK = -1)
BEGIN
    SET IDENTITY_INSERT dw.DimProduct ON;
    INSERT dw.DimProduct (ProductSK, ProductID, ProductName, IsDiscontinued, CategoryName, SupplierName, RowEffectiveDate)
    VALUES (-1, -1, N'Desconocido', 0, N'Desconocido', N'Desconocido', '1900-01-01');
    SET IDENTITY_INSERT dw.DimProduct OFF;
END
GO
IF NOT EXISTS (SELECT 1 FROM dw.DimEmployee WHERE EmployeeSK = -1)
BEGIN
    SET IDENTITY_INSERT dw.DimEmployee ON;
    INSERT dw.DimEmployee (EmployeeSK, EmployeeID, LastName, FirstName, FullName, RowEffectiveDate)
    VALUES (-1, -1, N'Desconocido', N'N/D', N'N/D Desconocido', '1900-01-01');
    SET IDENTITY_INSERT dw.DimEmployee OFF;
END
GO
IF NOT EXISTS (SELECT 1 FROM dw.DimShipper WHERE ShipperSK = -1)
BEGIN
    SET IDENTITY_INSERT dw.DimShipper ON;
    INSERT dw.DimShipper (ShipperSK, ShipperID, CompanyName, RowEffectiveDate)
    VALUES (-1, -1, N'Desconocido', '1900-01-01');
    SET IDENTITY_INSERT dw.DimShipper OFF;
END
GO
IF NOT EXISTS (SELECT 1 FROM dw.DimShipGeography WHERE ShipGeographySK = -1)
BEGIN
    SET IDENTITY_INSERT dw.DimShipGeography ON;
    INSERT dw.DimShipGeography (ShipGeographySK, ShipCity, ShipCountry, RowEffectiveDate)
    VALUES (-1, N'Desconocido', N'Desconocido', '1900-01-01');
    SET IDENTITY_INSERT dw.DimShipGeography OFF;
END
GO
