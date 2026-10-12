-- Tabla de Hechos: FactVentas
CREATE TABLE dbo.FactVentas (
    FactVentaID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClienteKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    EmpleadoKey INT NOT NULL,
    TransportistaKey INT NOT NULL,
    TiempoKey INT NOT NULL,
    OrdenID INT NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL,
    Cantidad INT NOT NULL,
    Descuento REAL NOT NULL,
    CostoEnvio DECIMAL(18,2) NULL,
    CONSTRAINT FK_FactVentas_Cliente FOREIGN KEY (ClienteKey) REFERENCES dbo.DimCliente(ClienteKey),
    CONSTRAINT FK_FactVentas_Producto FOREIGN KEY (ProductoKey) REFERENCES dbo.DimProducto(ProductoKey),
    CONSTRAINT FK_FactVentas_Empleado FOREIGN KEY (EmpleadoKey) REFERENCES dbo.DimEmpleado(EmpleadoKey),
    CONSTRAINT FK_FactVentas_Transportista FOREIGN KEY (TransportistaKey) REFERENCES dbo.DimTransportista(TransportistaKey),
    CONSTRAINT FK_FactVentas_Tiempo FOREIGN KEY (TiempoKey) REFERENCES dbo.DimTiempo(TiempoKey)
);
GO