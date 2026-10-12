CREATE TABLE [dbo].[DimTiempo] (
    [TiempoKey]       INT           NOT NULL,
    [Fecha]           DATE          NOT NULL,
    [Anio]            INT           NOT NULL,
    [Trimestre]       INT           NOT NULL,
    [Mes]             INT           NOT NULL,
    [NombreMes]       NVARCHAR (15) NOT NULL,
    [Dia]             INT           NOT NULL,
    [DiaSemana]       INT           NOT NULL,
    [NombreDiaSemana] NVARCHAR (15) NOT NULL,
    PRIMARY KEY CLUSTERED ([TiempoKey] ASC)
);

