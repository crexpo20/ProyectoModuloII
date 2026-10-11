CREATE TABLE [dbo].[Fact_Ventas] (
    [OrderID]          INT      NOT NULL,
    [SK_Tiempo]        INT      NOT NULL,
    [SK_Cliente]       INT      NOT NULL,
    [SK_Producto]      INT      NOT NULL,
    [SK_Empleado]      INT      NOT NULL,
    [SK_Transportista] INT      NOT NULL,
    [Quantity]         SMALLINT NOT NULL,
    [UnitPrice]        MONEY    NOT NULL,
    [Discount]         REAL     NOT NULL,
    [ExtendedPrice]    MONEY    NOT NULL,
    [Freight]          MONEY    NULL,
    CONSTRAINT [PK_Fact_Ventas] PRIMARY KEY CLUSTERED ([OrderID] ASC, [SK_Producto] ASC),
    CONSTRAINT [FK_Fact_Ventas_Dim_Tiempo] FOREIGN KEY ([SK_Tiempo]) REFERENCES [dbo].[Dim_Tiempo] ([SK_Tiempo]),
    CONSTRAINT [FK_Fact_Ventas_Dim_Cliente] FOREIGN KEY ([SK_Cliente]) REFERENCES [dbo].[Dim_Cliente] ([SK_Cliente]),
    CONSTRAINT [FK_Fact_Ventas_Dim_Producto] FOREIGN KEY ([SK_Producto]) REFERENCES [dbo].[Dim_Producto] ([SK_Producto]),
    CONSTRAINT [FK_Fact_Ventas_Dim_Empleado] FOREIGN KEY ([SK_Empleado]) REFERENCES [dbo].[Dim_Empleado] ([SK_Empleado]),
    CONSTRAINT [FK_Fact_Ventas_Dim_Transportista] FOREIGN KEY ([SK_Transportista]) REFERENCES [dbo].[Dim_Transportista] ([SK_Transportista])
);