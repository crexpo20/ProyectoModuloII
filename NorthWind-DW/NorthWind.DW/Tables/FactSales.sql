-- Tabla de hechos de ventas.
-- GRANULARIDAD: una fila por linea de pedido (OrderID + ProductID).
CREATE TABLE [dw].[FactSales] (
    [OrderID]          INT           NOT NULL,   -- dimension degenerada
    [ProductKey]       INT           NOT NULL,
    [CustomerKey]      INT           NOT NULL,
    [EmployeeKey]      INT           NOT NULL,
    [ShipperKey]       INT           NOT NULL,
    [ShipLocationKey]  INT           NOT NULL,
    [OrderDateKey]     INT           NOT NULL,
    [RequiredDateKey]  INT           NOT NULL,
    [ShippedDateKey]   INT           NOT NULL,   -- -1 si aun no se envia
    -- Medidas
    [UnitPrice]        DECIMAL(19,4) NOT NULL,
    [Quantity]         SMALLINT      NOT NULL,
    [Discount]         DECIMAL(5,2)  NOT NULL,   -- 0.05 = 5%
    [GrossAmount]      DECIMAL(19,4) NOT NULL,   -- UnitPrice * Quantity
    [DiscountAmount]   DECIMAL(19,4) NOT NULL,   -- GrossAmount * Discount
    [SalesAmount]      DECIMAL(19,4) NOT NULL,   -- GrossAmount - DiscountAmount (venta neta)
    [FreightAllocated] DECIMAL(19,4) NOT NULL,   -- Freight del pedido prorrateado por venta neta
    [DaysToShip]       INT           NULL,       -- dias entre pedido y envio (NULL si no enviado)
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([OrderID],[ProductKey]),
    CONSTRAINT [FK_FactSales_DimProduct]      FOREIGN KEY ([ProductKey])      REFERENCES [dw].[DimProduct]([ProductKey]),
    CONSTRAINT [FK_FactSales_DimCustomer]     FOREIGN KEY ([CustomerKey])     REFERENCES [dw].[DimCustomer]([CustomerKey]),
    CONSTRAINT [FK_FactSales_DimEmployee]     FOREIGN KEY ([EmployeeKey])     REFERENCES [dw].[DimEmployee]([EmployeeKey]),
    CONSTRAINT [FK_FactSales_DimShipper]      FOREIGN KEY ([ShipperKey])      REFERENCES [dw].[DimShipper]([ShipperKey]),
    CONSTRAINT [FK_FactSales_DimShipLocation] FOREIGN KEY ([ShipLocationKey]) REFERENCES [dw].[DimShipLocation]([ShipLocationKey]),
    CONSTRAINT [FK_FactSales_OrderDate]       FOREIGN KEY ([OrderDateKey])    REFERENCES [dw].[DimDate]([DateKey]),
    CONSTRAINT [FK_FactSales_RequiredDate]    FOREIGN KEY ([RequiredDateKey]) REFERENCES [dw].[DimDate]([DateKey]),
    CONSTRAINT [FK_FactSales_ShippedDate]     FOREIGN KEY ([ShippedDateKey])  REFERENCES [dw].[DimDate]([DateKey])
);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey] ON [dw].[FactSales]([OrderDateKey]);
GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerKey]  ON [dw].[FactSales]([CustomerKey]);
