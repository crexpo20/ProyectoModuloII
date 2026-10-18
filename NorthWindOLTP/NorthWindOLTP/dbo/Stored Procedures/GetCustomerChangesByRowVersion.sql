CREATE PROCEDURE [dbo].[GetCustomerChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
  SELECT 
     c.[CustomerID]
    ,c.[CompanyName]
    ,c.[ContactName]
    ,c.[ContactTitle]
    ,c.[Address]
    ,c.[City]
    ,c.[Region]
    ,c.[PostalCode]
    ,c.[Country]
    ,c.[Phone]
    ,c.[Fax]
    ,c.[rowversion]
    ,g.[CustomerDesc]
  FROM [dbo].[Customers] c
  LEFT JOIN [dbo].[CustomerCustomerDemo] d ON c.CustomerID = d.CustomerID
  LEFT JOIN [dbo].[CustomerDemographics] g ON d.CustomerTypeID = g.CustomerTypeID
  WHERE (CAST(c.[rowversion] AS BIGINT) > @startRow AND CAST(c.[rowversion] AS BIGINT) <= @endRow)
     OR (CAST(d.[rowversion] AS BIGINT) > @startRow AND CAST(d.[rowversion] AS BIGINT) <= @endRow)
     OR (CAST(g.[rowversion] AS BIGINT) > @startRow AND CAST(g.[rowversion] AS BIGINT) <= @endRow);
END