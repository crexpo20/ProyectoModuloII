CREATE TABLE [dbo].[DimEmpleado]
(
    [EmpleadoKey] INT IDENTITY(1,1) NOT NULL,
    [EmployeeID] INT NOT NULL,
    [Nombre] NVARCHAR(10) NOT NULL,
    [Apellido] NVARCHAR(20) NOT NULL,
    [Cargo] NVARCHAR(30) NULL,
    [Ciudad] NVARCHAR(15) NULL,
    [Region] NVARCHAR(15) NULL,
    [CodigoPostal] NVARCHAR(10) NULL,
    [Pais] NVARCHAR(15) NULL,
    [FechaContratacion] DATE NULL,
    CONSTRAINT [PK_DimEmpleado] PRIMARY KEY CLUSTERED ([EmpleadoKey]),
    CONSTRAINT [UQ_DimEmpleado_EmployeeID] UNIQUE ([EmployeeID])
);
