CREATE TABLE [dbo].[Dim_Transportista] (
    [SK_Transportista] INT           IDENTITY (1, 1) NOT NULL,
    [ShipperID]        INT           NOT NULL,
    [CompanyName]      NVARCHAR (40) NOT NULL,
    CONSTRAINT [PK_Dim_Transportista] PRIMARY KEY CLUSTERED ([SK_Transportista] ASC)
);

