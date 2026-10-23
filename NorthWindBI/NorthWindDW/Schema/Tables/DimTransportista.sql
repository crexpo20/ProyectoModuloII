CREATE TABLE [dbo].[DimTransportista]
(
    [TransportistaKey] INT IDENTITY(1,1) NOT NULL,
    [ShipperID] INT NOT NULL,
    [Empresa] NVARCHAR(40) NOT NULL,
    [Telefono] NVARCHAR(24) NULL,
    CONSTRAINT [PK_DimTransportista] PRIMARY KEY CLUSTERED ([TransportistaKey]),
    CONSTRAINT [UQ_DimTransportista_ShipperID] UNIQUE ([ShipperID])
);
