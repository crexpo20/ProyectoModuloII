-- Dimension Destino de envio (ciudad/region/pais donde se entrega el pedido). Origen: Orders.Ship*
CREATE TABLE [dw].[DimShipLocation] (
    [ShipLocationKey] INT IDENTITY(1,1) NOT NULL,
    [ShipCity]        NVARCHAR(15) NOT NULL,
    [ShipRegion]      NVARCHAR(15) NOT NULL,
    [ShipCountry]     NVARCHAR(15) NOT NULL,
    CONSTRAINT [PK_DimShipLocation] PRIMARY KEY CLUSTERED ([ShipLocationKey]),
    CONSTRAINT [UQ_DimShipLocation] UNIQUE ([ShipCity],[ShipRegion],[ShipCountry])
);
