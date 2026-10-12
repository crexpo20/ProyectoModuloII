CREATE TABLE dw.DimShipper(
    ShipperSK          int IDENTITY(1,1) NOT NULL,
    ShipperID          int            NOT NULL,   -- business key
    CompanyName        nvarchar(40)   NOT NULL,
    Phone              nvarchar(24)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimShipper_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimShipper_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimShipper_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimShipper PRIMARY KEY CLUSTERED (ShipperSK)
);

CREATE UNIQUE NONCLUSTERED INDEX UX_DimShipper_BK_Current ON dw.DimShipper (ShipperID) WHERE IsCurrent = 1;

CREATE NONCLUSTERED INDEX IX_DimShipper_BK_Dates ON dw.DimShipper (ShipperID, RowEffectiveDate, RowExpirationDate);
