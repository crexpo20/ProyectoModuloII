-- 1. Crear la base de datos del Data Warehouse
CREATE DATABASE Northwind_DW;
GO

USE Northwind_DW;
GO

-- 2. Crear Dimensión Cliente (Desnormalizada desde Customers)
CREATE TABLE Dim_Cliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(5) NOT NULL,
    NombreCompania NVARCHAR(40),
    NombreContacto NVARCHAR(30),
    Ciudad NVARCHAR(15),
    Pais NVARCHAR(15)
);

-- 3. Crear Dimensión Producto (Combina Products, Categories y Suppliers)
CREATE TABLE Dim_Producto (
    ProductoKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    NombreProducto NVARCHAR(40),
    NombreCategoria NVARCHAR(15),
    NombreProveedor NVARCHAR(40),
    PrecioUnitario MONEY
);

-- 4. Crear Dimensión Empleado (Desnormalizada desde Employees)
CREATE TABLE Dim_Empleado (
    EmpleadoKey INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    NombreCompleto NVARCHAR(50),
    Cargo NVARCHAR(30),
    Ciudad NVARCHAR(15),
    Pais NVARCHAR(15)
);

-- 5. Crear Dimensión Tiempo
CREATE TABLE Dim_Tiempo (
    TiempoKey INT PRIMARY KEY, -- Formato AAAAMMDD (Ej: 19960704)
    Fecha DATE,
    Anio INT,
    Trimestre INT,
    Mes INT,
    NombreMes NVARCHAR(15),
    DiaSemana NVARCHAR(15)
);

-- 6. Crear Tabla de Hechos (Fact_Ventas - Métricas de Orders y OrderDetails)
CREATE TABLE Fact_Ventas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ClienteKey INT FOREIGN KEY REFERENCES Dim_Cliente(ClienteKey),
    ProductoKey INT FOREIGN KEY REFERENCES Dim_Producto(ProductoKey),
    EmpleadoKey INT FOREIGN KEY REFERENCES Dim_Empleado(EmpleadoKey),
    TiempoKey INT FOREIGN KEY REFERENCES Dim_Tiempo(TiempoKey),
    PrecioUnitario MONEY,
    Cantidad SMALLINT,
    Descuento REAL,
    MontoTotal MONEY
);