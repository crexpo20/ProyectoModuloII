CREATE TABLE dw.DimShipGeography(
    ShipGeographySK    int IDENTITY(1,1) NOT NULL,
    ShipCity           nvarchar(15)   NULL,
    ShipRegion         nvarchar(15)   NULL,
    ShipPostalCode     nvarchar(10)   NULL,
    ShipCountry        nvarchar(15)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimShipGeo_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimShipGeo_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimShipGeo_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimShipGeography PRIMARY KEY CLUSTERED (ShipGeographySK)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimShipGeo_BK_Current
    ON dw.DimShipGeography (ShipCity, ShipRegion, ShipPostalCode, ShipCountry) WHERE IsCurrent = 1;
