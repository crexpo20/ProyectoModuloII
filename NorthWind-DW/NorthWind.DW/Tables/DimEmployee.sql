-- Dimension Empleado (vendedor). Incluye el nombre del jefe para evitar auto-join en BI
CREATE TABLE [dw].[DimEmployee] (
    [EmployeeKey]    INT IDENTITY(1,1) NOT NULL,
    [EmployeeID]     INT           NOT NULL,   -- llave de negocio
    [FullName]       NVARCHAR(40)  NOT NULL,
    [Title]          NVARCHAR(30)  NULL,
    [HireDate]       DATE          NULL,
    [City]           NVARCHAR(15)  NULL,
    [Country]        NVARCHAR(15)  NULL,
    [ReportsToName]  NVARCHAR(40)  NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED ([EmployeeKey]),
    CONSTRAINT [UQ_DimEmployee_EmployeeID] UNIQUE ([EmployeeID])
);
