-- Dimension Transportista. Origen: Shippers
CREATE TABLE [dw].[DimShipper] (
    [ShipperKey]  INT IDENTITY(1,1) NOT NULL,
    [ShipperID]   INT          NOT NULL,   -- llave de negocio
    [CompanyName] NVARCHAR(40) NOT NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED ([ShipperKey]),
    CONSTRAINT [UQ_DimShipper_ShipperID] UNIQUE ([ShipperID])
);
