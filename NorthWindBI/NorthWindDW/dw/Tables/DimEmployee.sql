CREATE TABLE dw.DimEmployee(
    EmployeeSK         int IDENTITY(1,1) NOT NULL,
    EmployeeID         int            NOT NULL,   -- business key
    LastName           nvarchar(20)   NOT NULL,
    FirstName          nvarchar(10)   NOT NULL,
    FullName           nvarchar(31)   NOT NULL,   -- FirstName + ' ' + LastName
    Title              nvarchar(30)   NULL,
    TitleOfCourtesy    nvarchar(25)   NULL,
    BirthDate          date           NULL,
    HireDate           date           NULL,
    Address            nvarchar(60)   NULL,
    City               nvarchar(15)   NULL,
    Region             nvarchar(15)   NULL,
    PostalCode         nvarchar(10)   NULL,
    Country            nvarchar(15)   NULL,
    HomePhone          nvarchar(24)   NULL,
    Extension          nvarchar(4)    NULL,
    PhotoPath          nvarchar(255)  NULL,
    -- Jefe directo (auto-referencia aplanada)
    ManagerEmployeeID  int            NULL,
    ManagerFullName    nvarchar(31)   NULL,
    ManagerTitle       nvarchar(30)   NULL,
    -- Control SCD2
    RowEffectiveDate   date           NOT NULL,
    RowExpirationDate  date           NOT NULL CONSTRAINT DF_DimEmployee_Exp DEFAULT ('9999-12-31'),
    IsCurrent          bit            NOT NULL CONSTRAINT DF_DimEmployee_Cur DEFAULT (1),
    RowHash            varbinary(32)  NULL,
    ETLBatchID         int            NULL,
    InsertedAt         datetime2(0)   NOT NULL CONSTRAINT DF_DimEmployee_Ins DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_DimEmployee PRIMARY KEY CLUSTERED (EmployeeSK)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_DimEmployee_BK_Current ON dw.DimEmployee (EmployeeID) WHERE IsCurrent = 1;
GO

CREATE NONCLUSTERED INDEX IX_DimEmployee_BK_Dates ON dw.DimEmployee (EmployeeID, RowEffectiveDate, RowExpirationDate);
