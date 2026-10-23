-- Dimension Cliente (SCD Tipo 1). Origen: Customers
CREATE TABLE [dw].[DimCustomer] (
    [CustomerKey]  INT IDENTITY(1,1) NOT NULL,
    [CustomerID]   NCHAR(5)     NOT NULL,   -- llave de negocio
    [CompanyName]  NVARCHAR(40) NOT NULL,
    [ContactName]  NVARCHAR(30) NULL,
    [ContactTitle] NVARCHAR(30) NULL,
    [City]         NVARCHAR(15) NULL,
    [Region]       NVARCHAR(15) NULL,
    [PostalCode]   NVARCHAR(10) NULL,
    [Country]      NVARCHAR(15) NULL,
    CONSTRAINT [PK_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey]),
    CONSTRAINT [UQ_DimCustomer_CustomerID] UNIQUE ([CustomerID])
);
