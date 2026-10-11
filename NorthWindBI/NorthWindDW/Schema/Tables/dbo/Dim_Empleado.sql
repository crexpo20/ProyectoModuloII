CREATE TABLE [dbo].[Dim_Empleado] (
    [SK_Empleado]          INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeID]           INT           NOT NULL,
    [NombreCompleto]       NVARCHAR (31) NOT NULL,
    [Title]                NVARCHAR (30) NULL,
    [City]                 NVARCHAR (15) NULL,
    [Country]              NVARCHAR (15) NULL,
    [TerritoryDescription] NVARCHAR (50) NULL,
    [RegionDescription]    NCHAR (50)    NULL,
    CONSTRAINT [PK_Dim_Empleado] PRIMARY KEY CLUSTERED ([SK_Empleado] ASC)
);