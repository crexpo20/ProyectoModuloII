CREATE TABLE dw.DimDate(
    DateKey          int          NOT NULL,   -- YYYYMMDD, -1 = desconocida / no enviada
    FullDate         date         NOT NULL,
    DayOfWeekNumber  tinyint      NOT NULL,   -- ISO: 1 = Lunes ... 7 = Domingo
    DayName          nvarchar(10) NOT NULL,
    DayOfMonth       tinyint      NOT NULL,
    DayOfYear        smallint     NOT NULL,
    WeekOfYearISO    tinyint      NOT NULL,
    MonthNumber      tinyint      NOT NULL,
    MonthName        nvarchar(12) NOT NULL,
    QuarterNumber    tinyint      NOT NULL,
    QuarterName      nchar(2)     NOT NULL,   -- T1..T4
    YearNumber       smallint     NOT NULL,
    YearMonth        char(7)      NOT NULL,   -- 1997-03
    YearQuarter      char(7)      NOT NULL,   -- 1997-T1
    IsWeekend        bit          NOT NULL,
    CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (DateKey),
    CONSTRAINT UQ_DimDate_FullDate UNIQUE (FullDate)
);
