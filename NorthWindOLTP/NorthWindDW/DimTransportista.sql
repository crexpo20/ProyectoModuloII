-- 4. Dimensión Transportista
CREATE TABLE dbo.DimTransportista (
    TransportistaKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TransportistaID INT NOT NULL,
    NombreCompania NVARCHAR(40) NOT NULL,
    Telefono NVARCHAR(24) NULL
);
GO