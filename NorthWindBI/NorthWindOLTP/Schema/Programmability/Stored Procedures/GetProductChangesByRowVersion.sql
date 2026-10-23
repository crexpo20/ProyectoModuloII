CREATE PROCEDURE [dbo].[GetEmployeeChangesByRowVersion] (
    @startRow BIGINT,
    @endRow   BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
       e.[EmployeeID]
      ,e.[LastName]
      ,e.[FirstName]
      ,e.[Title]
      ,e.[TitleOfCourtesy]
      ,e.[BirthDate]
      ,e.[HireDate]
      ,e.[Address]
      ,e.[City]
      ,e.[Region]
      ,e.[PostalCode]
      ,e.[Country]
      ,e.[HomePhone]
      ,e.[Extension]
      ,e.[Photo]
      ,e.[Notes]
      ,e.[ReportsTo]
      ,e.[PhotoPath]
      ,t.[TerritoryDescription]
      ,r.[RegionDescription]
    FROM [dbo].[Employees] e
    INNER JOIN [dbo].[EmployeeTerritories] et ON e.EmployeeID = et.EmployeeID
    INNER JOIN [dbo].[Territories] t ON et.TerritoryID = t.TerritoryID
    INNER JOIN [dbo].[Region] r ON t.RegionID = r.RegionID
    WHERE (CAST(e.[rowversion] AS BIGINT) > @startRow AND CAST(e.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(et.[rowversion] AS BIGINT) > @startRow AND CAST(et.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(t.[rowversion] AS BIGINT) > @startRow AND CAST(t.[rowversion] AS BIGINT) <= @endRow)
       OR (CAST(r.[rowversion] AS BIGINT) > @startRow AND CAST(r.[rowversion] AS BIGINT) <= @endRow);
END
GO