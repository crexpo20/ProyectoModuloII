CREATE TABLE dw.FactSales(
    SalesKey          bigint IDENTITY(1,1) NOT NULL,

    -- Llaves foráneas a dimensiones (SK). -1 = desconocido
    OrderDateKey      int           NOT NULL,
    RequiredDateKey   int           NOT NULL CONSTRAINT DF_FactSales_ReqDate  DEFAULT (-1),
    ShippedDateKey    int           NOT NULL CONSTRAINT DF_FactSales_ShipDate DEFAULT (-1),
    CustomerKey       int           NOT NULL CONSTRAINT DF_FactSales_Cust     DEFAULT (-1),
    ProductKey        int           NOT NULL CONSTRAINT DF_FactSales_Prod     DEFAULT (-1),
    EmployeeKey       int           NOT NULL CONSTRAINT DF_FactSales_Emp      DEFAULT (-1),
    ShipperKey        int           NOT NULL CONSTRAINT DF_FactSales_Shipper  DEFAULT (-1),
    ShipGeographyKey  int           NOT NULL CONSTRAINT DF_FactSales_Geo      DEFAULT (-1),

    -- Dimensión degenerada
    OrderID           int           NOT NULL,

    -- Métricas aditivas
    Quantity          smallint      NOT NULL,
    UnitPrice         decimal(19,4) NOT NULL,   -- precio realmente cobrado (semi-aditiva: no sumar)
    Discount          decimal(5,4)  NOT NULL,   -- porcentaje 0..1 (no aditiva)
    GrossAmount       decimal(19,4) NOT NULL,   -- Quantity * UnitPrice
    DiscountAmount    decimal(19,4) NOT NULL,   -- GrossAmount * Discount
    NetAmount         decimal(19,4) NOT NULL,   -- GrossAmount - DiscountAmount  ("total")
    FreightAllocated  decimal(19,4) NOT NULL CONSTRAINT DF_FactSales_Freight DEFAULT (0), -- flete prorrateado por línea

    -- Auditoría
    ETLBatchID        int           NULL,
    LoadDateTime      datetime2(0)  NOT NULL CONSTRAINT DF_FactSales_Load DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_FactSales PRIMARY KEY CLUSTERED (SalesKey),
    CONSTRAINT UQ_FactSales_Grain UNIQUE NONCLUSTERED (OrderID, ProductKey),  -- evita duplicar líneas

    CONSTRAINT FK_FactSales_OrderDate    FOREIGN KEY (OrderDateKey)     REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSales_RequiredDate FOREIGN KEY (RequiredDateKey)  REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSales_ShippedDate  FOREIGN KEY (ShippedDateKey)   REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactSales_Customer     FOREIGN KEY (CustomerKey)      REFERENCES dw.DimCustomer(CustomerSK),
    CONSTRAINT FK_FactSales_Product      FOREIGN KEY (ProductKey)       REFERENCES dw.DimProduct(ProductSK),
    CONSTRAINT FK_FactSales_Employee     FOREIGN KEY (EmployeeKey)      REFERENCES dw.DimEmployee(EmployeeSK),
    CONSTRAINT FK_FactSales_Shipper      FOREIGN KEY (ShipperKey)       REFERENCES dw.DimShipper(ShipperSK),
    CONSTRAINT FK_FactSales_ShipGeo      FOREIGN KEY (ShipGeographyKey) REFERENCES dw.DimShipGeography(ShipGeographySK)
);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_OrderDate   ON dw.FactSales (OrderDateKey)    INCLUDE (NetAmount, Quantity);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_Customer    ON dw.FactSales (CustomerKey)     INCLUDE (NetAmount);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_Product     ON dw.FactSales (ProductKey)      INCLUDE (NetAmount, Quantity);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_Employee    ON dw.FactSales (EmployeeKey)     INCLUDE (NetAmount);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_Shipper     ON dw.FactSales (ShipperKey)      INCLUDE (FreightAllocated);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_ShipDate    ON dw.FactSales (ShippedDateKey);
GO

CREATE NONCLUSTERED INDEX IX_FactSales_ShipGeo     ON dw.FactSales (ShipGeographyKey);
