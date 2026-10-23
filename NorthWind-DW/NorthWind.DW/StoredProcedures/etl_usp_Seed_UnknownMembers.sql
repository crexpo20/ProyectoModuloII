-- Crea el miembro "Desconocido" (clave -1) en cada dimension para no perder filas cuando
-- el origen trae NULL en una llave (p. ej. pedido sin cliente o aun no enviado).
CREATE PROCEDURE [etl].[usp_Seed_UnknownMembers]
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimDate] WHERE DateKey = -1)
        INSERT [dw].[DimDate] (DateKey, FullDate, [Year], [Quarter], QuarterName, [Month], [MonthName], YearMonth,
                               [DayOfMonth], [DayOfWeek], [DayName], WeekOfYear, IsWeekend)
        VALUES (-1, '19000101', 1900, 1, N'N/D', 1, N'N/D', '1900-01', 1, 1, N'N/D', 1, 0);

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimCustomer] WHERE CustomerKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimCustomer] ON;
        INSERT [dw].[DimCustomer] (CustomerKey, CustomerID, CompanyName) VALUES (-1, N'-1', N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimCustomer] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimProduct] WHERE ProductKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimProduct] ON;
        INSERT [dw].[DimProduct] (ProductKey, ProductID, ProductName, Discontinued, CategoryName, SupplierName)
        VALUES (-1, -1, N'Desconocido', 0, N'Sin categoria', N'Sin proveedor');
        SET IDENTITY_INSERT [dw].[DimProduct] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimEmployee] WHERE EmployeeKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimEmployee] ON;
        INSERT [dw].[DimEmployee] (EmployeeKey, EmployeeID, FullName) VALUES (-1, -1, N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimEmployee] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimShipper] WHERE ShipperKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimShipper] ON;
        INSERT [dw].[DimShipper] (ShipperKey, ShipperID, CompanyName) VALUES (-1, -1, N'Desconocido');
        SET IDENTITY_INSERT [dw].[DimShipper] OFF;
    END

    IF NOT EXISTS (SELECT 1 FROM [dw].[DimShipLocation] WHERE ShipLocationKey = -1)
    BEGIN
        SET IDENTITY_INSERT [dw].[DimShipLocation] ON;
        INSERT [dw].[DimShipLocation] (ShipLocationKey, ShipCity, ShipRegion, ShipCountry) VALUES (-1, N'N/D', N'N/D', N'N/D');
        SET IDENTITY_INSERT [dw].[DimShipLocation] OFF;
    END
END
