-- 1. Dimensión Cliente
CREATE TABLE dbo.DimCliente (
    ClienteKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteID NVARCHAR(5) NOT NULL,
    NombreCompania NVARCHAR(40) NOT NULL,
    NombreContacto NVARCHAR(30) NULL,
    TituloContacto NVARCHAR(30) NULL,
    Direccion NVARCHAR(60) NULL,
    Ciudad NVARCHAR(15) NULL,
    Region NVARCHAR(15) NULL,
    CodigoPostal NVARCHAR(10) NULL,
    Pais NVARCHAR(15) NULL
);
GO