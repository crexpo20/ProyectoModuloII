/* DimDate: miembro desconocido + calendario 1995-2030 (solo si aún no existe) */
IF NOT EXISTS (SELECT 1 FROM dw.DimDate WHERE DateKey = -1)
    INSERT dw.DimDate (DateKey, FullDate, DayOfWeekNumber, DayName, DayOfMonth, DayOfYear, WeekOfYearISO, MonthNumber, MonthName, QuarterNumber, QuarterName, YearNumber, YearMonth, YearQuarter, IsWeekend)
    VALUES (-1, '1900-01-01', 1, N'N/D', 1, 1, 1, 1, N'N/D', 1, N'T1', 1900, '1900-01', '1900-T1', 0);
GO

IF NOT EXISTS (SELECT 1 FROM dw.DimDate WHERE DateKey = 19950101)
BEGIN
DECLARE @Start date = '1995-01-01', @End date = '2030-12-31';

;WITH d AS (
    SELECT @Start AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt) FROM d WHERE dt < @End
)
INSERT dw.DimDate (DateKey, FullDate, DayOfWeekNumber, DayName, DayOfMonth, DayOfYear, WeekOfYearISO,
                   MonthNumber, MonthName, QuarterNumber, QuarterName, YearNumber, YearMonth, YearQuarter, IsWeekend)
SELECT  CONVERT(int, CONVERT(char(8), dt, 112)),
        dt,
        x.IsoDow,
        CHOOSE(x.IsoDow, N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo'),
        DAY(dt),
        DATEPART(DAYOFYEAR, dt),
        DATEPART(ISO_WEEK, dt),
        MONTH(dt),
        CHOOSE(MONTH(dt), N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio',
                          N'Julio', N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre'),
        DATEPART(QUARTER, dt),
        CONCAT(N'T', DATEPART(QUARTER, dt)),
        YEAR(dt),
        LEFT(CONVERT(char(10), dt, 120), 7),
        CONCAT(YEAR(dt), '-T', DATEPART(QUARTER, dt)),
        CASE WHEN x.IsoDow >= 6 THEN 1 ELSE 0 END
FROM d
CROSS APPLY (SELECT ((DATEPART(WEEKDAY, dt) + @@DATEFIRST - 2) % 7) + 1 AS IsoDow) AS x
OPTION (MAXRECURSION 0);
END
GO
