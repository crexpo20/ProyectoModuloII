-- Dimension Fecha (rol multiple: pedido, requerida, envio). DateKey = yyyymmdd. -1 = no definida
CREATE TABLE [dw].[DimDate] (
    [DateKey]     INT          NOT NULL,
    [FullDate]    DATE         NOT NULL,
    [Year]        SMALLINT     NOT NULL,
    [Quarter]     TINYINT      NOT NULL,
    [QuarterName] NVARCHAR(10) NOT NULL,
    [Month]       TINYINT      NOT NULL,
    [MonthName]   NVARCHAR(20) NOT NULL,
    [YearMonth]   CHAR(7)      NOT NULL,
    [DayOfMonth]  TINYINT      NOT NULL,
    [DayOfWeek]   TINYINT      NOT NULL,
    [DayName]     NVARCHAR(20) NOT NULL,
    [WeekOfYear]  TINYINT      NOT NULL,
    [IsWeekend]   BIT          NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey])
);
