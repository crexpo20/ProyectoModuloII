-- Genera la dimension fecha cubriendo los anios completos presentes en Orders (pedido/requerida/envio)
CREATE PROCEDURE [etl].[usp_Load_DimDate]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @min DATE, @max DATE;

    SELECT @min = MIN(d), @max = MAX(d)
    FROM (SELECT CAST(OrderDate AS DATE) d FROM [NorthWind].[dbo].[Orders]
          UNION ALL SELECT CAST(RequiredDate AS DATE) FROM [NorthWind].[dbo].[Orders]
          UNION ALL SELECT CAST(ShippedDate AS DATE)  FROM [NorthWind].[dbo].[Orders]) x
    WHERE d IS NOT NULL;

    IF @min IS NULL RETURN;  -- origen sin pedidos

    SET @min = DATEFROMPARTS(YEAR(@min), 1, 1);
    SET @max = DATEFROMPARTS(YEAR(@max), 12, 31);

    ;WITH dates AS (
        SELECT @min AS d
        UNION ALL
        SELECT DATEADD(DAY, 1, d) FROM dates WHERE d < @max
    )
    INSERT [dw].[DimDate] (DateKey, FullDate, [Year], [Quarter], QuarterName, [Month], [MonthName], YearMonth,
                           [DayOfMonth], [DayOfWeek], [DayName], WeekOfYear, IsWeekend)
    SELECT CONVERT(INT, CONVERT(CHAR(8), d, 112)),
           d,
           YEAR(d),
           DATEPART(QUARTER, d),
           N'T' + CAST(DATEPART(QUARTER, d) AS NVARCHAR(1)),
           MONTH(d),
           CHOOSE(MONTH(d), N'Enero',N'Febrero',N'Marzo',N'Abril',N'Mayo',N'Junio',N'Julio',N'Agosto',N'Septiembre',N'Octubre',N'Noviembre',N'Diciembre'),
           CONVERT(CHAR(7), d, 126),
           DAY(d),
           (DATEDIFF(DAY, '19000101', d) % 7) + 1,     -- 1 = lunes ... 7 = domingo
           CHOOSE((DATEDIFF(DAY, '19000101', d) % 7) + 1, N'Lunes',N'Martes',N'Miercoles',N'Jueves',N'Viernes',N'Sabado',N'Domingo'),
           DATEPART(ISO_WEEK, d),
           CASE WHEN (DATEDIFF(DAY, '19000101', d) % 7) + 1 >= 6 THEN 1 ELSE 0 END
    FROM dates
    WHERE CONVERT(INT, CONVERT(CHAR(8), d, 112)) NOT IN (SELECT DateKey FROM [dw].[DimDate])
    OPTION (MAXRECURSION 0);
END
