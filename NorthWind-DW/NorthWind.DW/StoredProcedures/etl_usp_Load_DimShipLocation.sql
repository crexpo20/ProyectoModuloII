-- Combinaciones distintas de ciudad/region/pais de envio presentes en Orders
CREATE PROCEDURE [etl].[usp_Load_DimShipLocation]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT [dw].[DimShipLocation] (ShipCity, ShipRegion, ShipCountry)
    SELECT DISTINCT ISNULL(o.ShipCity, N'N/D'), ISNULL(o.ShipRegion, N'N/D'), ISNULL(o.ShipCountry, N'N/D')
    FROM [NorthWind].[dbo].[Orders] o
    WHERE NOT EXISTS (SELECT 1 FROM [dw].[DimShipLocation] d
                      WHERE d.ShipCity    = ISNULL(o.ShipCity, N'N/D')
                        AND d.ShipRegion  = ISNULL(o.ShipRegion, N'N/D')
                        AND d.ShipCountry = ISNULL(o.ShipCountry, N'N/D'));
END
