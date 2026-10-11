USE Northwind_DW;
GO

-- 1. Limpiar las tablas para empezar de cero
DELETE FROM Fact_Ventas;
DELETE FROM Dim_Cliente;
DELETE FROM Dim_Producto;
DELETE FROM Dim_Empleado;
DELETE FROM Dim_Tiempo;

DBCC CHECKIDENT ('Dim_Cliente', RESEED, 0);
DBCC CHECKIDENT ('Dim_Producto', RESEED, 0);
DBCC CHECKIDENT ('Dim_Empleado', RESEED, 0);
DBCC CHECKIDENT ('Fact_Ventas', RESEED, 0);
GO

-- 2. Poblar Dimensiones
INSERT INTO Dim_Cliente (CustomerID, NombreCompania, NombreContacto, Ciudad, Pais)
SELECT CustomerID, CompanyName, ContactName, City, Country
FROM NorthWind.dbo.Customers;

INSERT INTO Dim_Producto (ProductID, NombreProducto, NombreCategoria, NombreProveedor, PrecioUnitario)
SELECT p.ProductID, p.ProductName, c.CategoryName, s.CompanyName, p.UnitPrice
FROM NorthWind.dbo.Products p
JOIN NorthWind.dbo.Categories c ON p.CategoryID = c.CategoryID
JOIN NorthWind.dbo.Suppliers s ON p.SupplierID = s.SupplierID;

INSERT INTO Dim_Empleado (EmployeeID, NombreCompleto, Cargo, Ciudad, Pais)
SELECT EmployeeID, FirstName + ' ' + LastName, Title, City, Country
FROM NorthWind.dbo.Employees;

INSERT INTO Dim_Tiempo (TiempoKey, Fecha, Anio, Trimestre, Mes, NombreMes, DiaSemana)
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), OrderDate, 112) AS INT) AS TiempoKey,
    CAST(OrderDate AS DATE) AS Fecha,
    YEAR(OrderDate) AS Anio,
    DATEPART(QUARTER, OrderDate) AS Trimestre,
    MONTH(OrderDate) AS Mes,
    DATENAME(MONTH, OrderDate) AS NombreMes,
    DATENAME(WEEKDAY, OrderDate) AS DiaSemana
FROM NorthWind.dbo.Orders
WHERE OrderDate IS NOT NULL;

-- 3. Poblar Fact_Ventas sin duplicados
INSERT INTO Fact_Ventas (OrderID, ClienteKey, ProductoKey, EmpleadoKey, TiempoKey, PrecioUnitario, Cantidad, Descuento, MontoTotal)
SELECT
    o.OrderID,
    dc.ClienteKey,
    dp.ProductoKey,
    de.EmpleadoKey,
    CAST(CONVERT(VARCHAR(8), o.OrderDate, 112) AS INT) AS TiempoKey,
    od.UnitPrice,
    od.Quantity,
    od.Discount,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS MontoTotal
FROM NorthWind.dbo.Orders o
JOIN NorthWind.dbo.OrderDetails od ON o.OrderID = od.OrderID
JOIN Dim_Cliente dc ON o.CustomerID = dc.CustomerID
JOIN Dim_Producto dp ON od.ProductID = dp.ProductID
JOIN Dim_Empleado de ON o.EmployeeID = de.EmployeeID;