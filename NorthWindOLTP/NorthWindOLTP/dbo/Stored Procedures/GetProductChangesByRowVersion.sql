CREATE PROCEDURE [dbo].[GetProductChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
       p.[ProductID]
      ,p.[ProductName]
      ,s.[CompanyName]
      ,c.[CategoryName]
      ,p.[QuantityPerUnit]
      ,p.[UnitPrice]
      ,p.[UnitsInStock]
      ,p.[UnitsOnOrder]
      ,p.[ReorderLevel]
      ,p.[Discontinued]
    FROM [dbo].[Products] p
    INNER JOIN [dbo].[Categories] c ON p.CategoryID = c.CategoryID
    INNER JOIN [dbo].[Suppliers] s ON p.SupplierID = s.SupplierID
    WHERE (CAST(p.[rowversion] AS BIGINT) > @startRow AND CAST(p.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(c.[rowversion] AS BIGINT) > @startRow AND CAST(c.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(s.[rowversion] AS BIGINT) > @startRow AND CAST(s.[rowversion] AS BIGINT) <= @endRow);
END