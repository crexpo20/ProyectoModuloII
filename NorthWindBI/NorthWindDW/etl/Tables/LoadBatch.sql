CREATE TABLE etl.LoadBatch(
    ETLBatchID     int IDENTITY(1,1) NOT NULL,
    StartTime      datetime2(0)  NOT NULL CONSTRAINT DF_LoadBatch_Start DEFAULT (SYSDATETIME()),
    EndTime        datetime2(0)  NULL,
    Status         varchar(15)   NOT NULL CONSTRAINT DF_LoadBatch_Status DEFAULT ('RUNNING'), -- RUNNING / SUCCESS / FAILED
    RowsExtracted  int           NULL,
    ErrorMessage   nvarchar(4000) NULL,
    CONSTRAINT PK_LoadBatch PRIMARY KEY CLUSTERED (ETLBatchID)
);
