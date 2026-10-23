-- Desnormaliza Products + Categories + Suppliers en una sola dimension
CREATE PROCEDURE [etl].[usp_Load_DimProduct]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimProduct] AS t
    USING (SELECT p.ProductID, p.ProductName, p.QuantityPerUnit,
                  CAST(p.UnitPrice AS DECIMAL(19,4)) AS ListUnitPrice, p.Discontinued,
                  p.CategoryID, ISNULL(c.CategoryName, N'Sin categoria') AS CategoryName, c.[Description] AS CategoryDescription,
                  p.SupplierID, ISNULL(s.CompanyName, N'Sin proveedor') AS SupplierName, s.City AS SupplierCity, s.Country AS SupplierCountry
           FROM [NorthWind].[dbo].[Products] p
           LEFT JOIN [NorthWind].[dbo].[Categories] c ON c.CategoryID = p.CategoryID
           LEFT JOIN [NorthWind].[dbo].[Suppliers]  s ON s.SupplierID = p.SupplierID) AS src
       ON t.ProductID = src.ProductID
    WHEN MATCHED THEN UPDATE SET
         ProductName = src.ProductName, QuantityPerUnit = src.QuantityPerUnit, ListUnitPrice = src.ListUnitPrice,
         Discontinued = src.Discontinued, CategoryID = src.CategoryID, CategoryName = src.CategoryName,
         CategoryDescription = src.CategoryDescription, SupplierID = src.SupplierID, SupplierName = src.SupplierName,
         SupplierCity = src.SupplierCity, SupplierCountry = src.SupplierCountry
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (ProductID, ProductName, QuantityPerUnit, ListUnitPrice, Discontinued, CategoryID, CategoryName,
                 CategoryDescription, SupplierID, SupplierName, SupplierCity, SupplierCountry)
         VALUES (src.ProductID, src.ProductName, src.QuantityPerUnit, src.ListUnitPrice, src.Discontinued, src.CategoryID,
                 src.CategoryName, src.CategoryDescription, src.SupplierID, src.SupplierName, src.SupplierCity, src.SupplierCountry);
END
