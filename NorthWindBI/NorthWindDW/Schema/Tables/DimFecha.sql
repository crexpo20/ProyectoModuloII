CREATE TABLE [dbo].[DimFecha]
(
    [FechaKey] INT NOT NULL,
    [Fecha] DATE NOT NULL,
    [Dia] TINYINT NOT NULL,
    [Mes] TINYINT NOT NULL,
    [NombreMes] NVARCHAR(15) NOT NULL,
    [Trimestre] TINYINT NOT NULL,
    [Anio] SMALLINT NOT NULL,
    [DiaSemana] TINYINT NOT NULL,
    [NombreDia] NVARCHAR(15) NOT NULL,
    [EsFinDeSemana] BIT NOT NULL,
    CONSTRAINT [PK_DimFecha] PRIMARY KEY CLUSTERED ([FechaKey]),
    CONSTRAINT [UQ_DimFecha_Fecha] UNIQUE ([Fecha]),
    CONSTRAINT [CK_DimFecha_Dia] CHECK ([Dia] BETWEEN 1 AND 31),
    CONSTRAINT [CK_DimFecha_Mes] CHECK ([Mes] BETWEEN 1 AND 12),
    CONSTRAINT [CK_DimFecha_Trimestre] CHECK ([Trimestre] BETWEEN 1 AND 4)
);
