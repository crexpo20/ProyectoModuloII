CREATE PROCEDURE [etl].[usp_Load_DimEmployee]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimEmployee] AS t
    USING (SELECT e.EmployeeID, e.FirstName + N' ' + e.LastName AS FullName, e.Title,
                  CAST(e.HireDate AS DATE) AS HireDate, e.City, e.Country,
                  b.FirstName + N' ' + b.LastName AS ReportsToName
           FROM [NorthWind].[dbo].[Employees] e
           LEFT JOIN [NorthWind].[dbo].[Employees] b ON b.EmployeeID = e.ReportsTo) AS s
       ON t.EmployeeID = s.EmployeeID
    WHEN MATCHED THEN UPDATE SET
         FullName = s.FullName, Title = s.Title, HireDate = s.HireDate, City = s.City,
         Country = s.Country, ReportsToName = s.ReportsToName
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (EmployeeID, FullName, Title, HireDate, City, Country, ReportsToName)
         VALUES (s.EmployeeID, s.FullName, s.Title, s.HireDate, s.City, s.Country, s.ReportsToName);
END
