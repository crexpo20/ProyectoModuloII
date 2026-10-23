CREATE TABLE [dbo].[FactVentas]
(
    [VentaKey] BIGINT IDENTITY(1,1) NOT NULL,
    [OrderID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [FechaPedidoKey] INT NULL,
    [FechaRequeridaKey] INT NULL,
    [FechaEnvioKey] INT NULL,
    [ClienteKey] INT NULL,
    [ProductoKey] INT NOT NULL,
    [EmpleadoKey] INT NULL,
    [TransportistaKey] INT NULL,
    [Cantidad] SMALLINT NOT NULL,
    [PrecioUnitario] DECIMAL(19,4) NOT NULL,
    [Descuento] DECIMAL(9,6) NOT NULL,
    [ImporteBruto] DECIMAL(19,4) NOT NULL,
    [ImporteDescuento] DECIMAL(19,4) NOT NULL,
    [ImporteNeto] DECIMAL(19,4) NOT NULL,
    CONSTRAINT [PK_FactVentas] PRIMARY KEY CLUSTERED ([VentaKey]),
    CONSTRAINT [UQ_FactVentas_PedidoProducto] UNIQUE ([OrderID], [ProductID]),
    CONSTRAINT [FK_FactVentas_FechaPedido] FOREIGN KEY ([FechaPedidoKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]),
    CONSTRAINT [FK_FactVentas_FechaRequerida] FOREIGN KEY ([FechaRequeridaKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]),
    CONSTRAINT [FK_FactVentas_FechaEnvio] FOREIGN KEY ([FechaEnvioKey]) REFERENCES [dbo].[DimFecha] ([FechaKey]),
    CONSTRAINT [FK_FactVentas_Cliente] FOREIGN KEY ([ClienteKey]) REFERENCES [dbo].[DimCliente] ([ClienteKey]),
    CONSTRAINT [FK_FactVentas_Producto] FOREIGN KEY ([ProductoKey]) REFERENCES [dbo].[DimProducto] ([ProductoKey]),
    CONSTRAINT [FK_FactVentas_Empleado] FOREIGN KEY ([EmpleadoKey]) REFERENCES [dbo].[DimEmpleado] ([EmpleadoKey]),
    CONSTRAINT [FK_FactVentas_Transportista] FOREIGN KEY ([TransportistaKey]) REFERENCES [dbo].[DimTransportista] ([TransportistaKey]),
    CONSTRAINT [CK_FactVentas_Cantidad] CHECK ([Cantidad] > 0),
    CONSTRAINT [CK_FactVentas_Precio] CHECK ([PrecioUnitario] >= 0),
    CONSTRAINT [CK_FactVentas_Descuento] CHECK ([Descuento] >= 0 AND [Descuento] <= 1),
    CONSTRAINT [CK_FactVentas_Importes] CHECK ([ImporteBruto] >= 0 AND [ImporteDescuento] >= 0 AND [ImporteNeto] >= 0)
);
GO
CREATE INDEX [IX_FactVentas_FechaPedido] ON [dbo].[FactVentas] ([FechaPedidoKey]);
GO
CREATE INDEX [IX_FactVentas_Cliente] ON [dbo].[FactVentas] ([ClienteKey]);
GO
CREATE INDEX [IX_FactVentas_Producto] ON [dbo].[FactVentas] ([ProductoKey]);
GO
CREATE INDEX [IX_FactVentas_Empleado] ON [dbo].[FactVentas] ([EmpleadoKey]);
