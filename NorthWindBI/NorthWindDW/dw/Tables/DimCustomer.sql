CREATE TABLE dw.DimCustomer(
    CustomerSK         int IDENTITY(1,1) NOT NULL,
    CustomerID         nchar(5)      NOT NULL,   -- business key
    CompanyName        nvarchar(40)  NOT NULL,
    ContactName        nvarchar(30)  NULL,
    ContactTitle       nvarchar(30)  NULL,
    Address            nvarchar(60)  NULL,
    City               nvarchar(15)  NULL,
    Region             nvarchar(15)  NULL,
    PostalCode         nvarchar(10)  NULL,
    Country            nvarchar(15)  NULL,
    Phone              nvarchar(24)  NULL,
    Fax                nvarchar(24)  NULL,
    -- Control SCD2
    RowEffectiveDate   date          NOT NULL,
    RowExpirationDate  date          NOT NULL CONSTRAINT DF_DimCustomer_Exp  DEFAULT ('9999-12-31'),
    IsCurrent          bit           NOT NULL CONSTRAINT DF_DimCustomer_Cur  DEFAULT (1),
    RowHash            varbinary(32) NULL,       -- SHA2_256 de atributos Tipo 2
    ETLBatchID         int           NULL,
    InsertedAt         datetime2(0)  NOT NULL CONSTRAINT DF_DimCustomer_Ins  DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimCustomer PRIMARY KEY CLUSTERED (CustomerSK)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimCustomer_BK_Current ON dw.DimCustomer (CustomerID) WHERE IsCurrent = 1;
GO

CREATE NONCLUSTERED INDEX IX_DimCustomer_BK_Dates ON dw.DimCustomer (CustomerID, RowEffectiveDate, RowExpirationDate);
