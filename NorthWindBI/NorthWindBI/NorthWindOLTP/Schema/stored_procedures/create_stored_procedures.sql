GO

/* ==========================================================
   SP: GetDatabaseRowVersion
   ========================================================== */
CREATE PROCEDURE [dbo].[GetDatabaseRowVersion]
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
	SELECT DBTS = (CONVERT(BIGINT,MIN_ACTIVE_ROWVERSION())-1);
END
GO

/* ==========================================================
   SP: GetCustomerChangesByRowVersion (CORREGIDO)
   ========================================================== */
CREATE PROCEDURE [dbo].[GetCustomerChangesByRowVersion]
(
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
  SELECT c.[CustomerID], c.[CompanyName], c.[ContactName], c.[ContactTitle],
         c.[Address], c.[City], c.[Region], c.[PostalCode], c.[Country],
         c.[Phone], c.[Fax], c.[rowversion], g.[CustomerDesc]
  FROM [dbo].[Customers] c
  LEFT JOIN [dbo].[CustomerCustomerDemo] d ON c.CustomerID = d.CustomerID
  LEFT JOIN [dbo].[CustomerDemographics] g ON d.CustomerTypeID = g.CustomerTypeID
  WHERE
    (c.[rowversion] > CONVERT(ROWVERSION,@startRow) AND c.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (d.[rowversion] > CONVERT(ROWVERSION,@startRow) AND d.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (g.[rowversion] > CONVERT(ROWVERSION,@startRow) AND g.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END
GO

/* ==========================================================
   SP: GetProductChangesByRowVersion
   ========================================================== */
CREATE PROCEDURE [dbo].[GetProductChangesByRowVersion]
(
   @startRow BIGINT,
   @endRow   BIGINT
)
AS
BEGIN
  SELECT p.[ProductID], p.[ProductName], s.[CompanyName],
         c.[CategoryName], p.[QuantityPerUnit], p.[UnitPrice],
         p.[UnitsInStock], p.[UnitsOnOrder], p.[ReorderLevel], p.[Discontinued]
  FROM [dbo].[Products] p
  INNER JOIN [dbo].[Categories] c ON p.CategoryID = c.CategoryID
  INNER JOIN [dbo].[Suppliers] s ON p.SupplierID = s.SupplierID
  WHERE
    (p.[rowversion] > CONVERT(ROWVERSION,@startRow) AND p.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (c.[rowversion] > CONVERT(ROWVERSION,@startRow) AND c.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (s.[rowversion] > CONVERT(ROWVERSION,@startRow) AND s.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END
GO

/* ==========================================================
   SP: GetEmployeeChangesByRowVersion
   ========================================================== */
CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion]
(
   @startRow BIGINT,
   @endRow   BIGINT
)
AS
BEGIN
  SELECT e.[EmployeeID], e.[LastName], e.[FirstName], e.[Title],
         e.[TitleOfCourtesy], e.[BirthDate], e.[HireDate], e.[Address],
         e.[City], e.[Region], e.[PostalCode], e.[Country], e.[HomePhone],
         e.[Extension], e.[Photo], e.[Notes], e.[ReportsTo], e.[PhotoPath],
         t.[TerritoryDescription], r.[RegionDescription]
  FROM [dbo].[Employees] e
  INNER JOIN [dbo].[EmployeeTerritories] et ON e.EmployeeID = et.EmployeeID
  INNER JOIN [dbo].[Territories] t ON et.TerritoryID = t.TerritoryID
  INNER JOIN [dbo].[Region] r ON t.RegionID = r.RegionID
  WHERE
    (e.[rowversion] > CONVERT(ROWVERSION,@startRow) AND e.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (et.[rowversion] > CONVERT(ROWVERSION,@startRow) AND et.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (t.[rowversion] > CONVERT(ROWVERSION,@startRow) AND t.[rowversion] <= CONVERT(ROWVERSION,@endRow))
    OR (r.[rowversion] > CONVERT(ROWVERSION,@startRow) AND r.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END
GO