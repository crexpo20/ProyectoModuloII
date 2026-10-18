CREATE TABLE [dbo].[Dim_Cliente] (
    [SK_Cliente]   INT            IDENTITY (1, 1) NOT NULL,
    [CustomerID]   NCHAR (5)      NOT NULL,
    [CompanyName]  NVARCHAR (40)  NOT NULL,
    [ContactName]  NVARCHAR (30)  NULL,
    [City]         NVARCHAR (15)  NULL,
    [Region]       NVARCHAR (15)  NULL,
    [Country]      NVARCHAR (15)  NULL,
    [CustomerDesc] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Dim_Cliente] PRIMARY KEY CLUSTERED ([SK_Cliente] ASC)
);

