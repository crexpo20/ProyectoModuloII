CREATE TABLE [dbo].[DimEmpleado] (
    [EmpleadoKey]     INT           IDENTITY (1, 1) NOT NULL,
    [EmpleadoID]      INT           NOT NULL,
    [NombreCompleto]  NVARCHAR (80) NOT NULL,
    [Cargo]           NVARCHAR (30) NULL,
    [FechaNacimiento] DATE          NULL,
    [Ciudad]          NVARCHAR (15) NULL,
    [Pais]            NVARCHAR (15) NULL,
    PRIMARY KEY CLUSTERED ([EmpleadoKey] ASC)
);

