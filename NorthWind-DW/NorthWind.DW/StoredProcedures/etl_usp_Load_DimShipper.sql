CREATE PROCEDURE [etl].[usp_Load_DimShipper]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimShipper] AS t
    USING (SELECT ShipperID, CompanyName FROM [NorthWind].[dbo].[Shippers]) AS s
       ON t.ShipperID = s.ShipperID
    WHEN MATCHED THEN UPDATE SET CompanyName = s.CompanyName
    WHEN NOT MATCHED BY TARGET THEN INSERT (ShipperID, CompanyName) VALUES (s.ShipperID, s.CompanyName);
END
