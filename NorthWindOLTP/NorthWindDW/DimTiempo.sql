-- 5. Dimensión Tiempo
CREATE TABLE dbo.DimTiempo (
    TiempoKey INT NOT NULL PRIMARY KEY, -- Formato AAAAMMDD (ej. 19960704)
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL,
    NombreMes NVARCHAR(15) NOT NULL,
    Dia INT NOT NULL,
    DiaSemana INT NOT NULL,
    NombreDiaSemana NVARCHAR(15) NOT NULL
);
GO
