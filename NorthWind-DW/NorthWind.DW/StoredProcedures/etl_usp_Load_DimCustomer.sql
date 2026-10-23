CREATE PROCEDURE [etl].[usp_Load_DimCustomer]
AS
BEGIN
    SET NOCOUNT ON;
    MERGE [dw].[DimCustomer] AS t
    USING (SELECT CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country
           FROM [NorthWind].[dbo].[Customers]) AS s
       ON t.CustomerID = s.CustomerID
    WHEN MATCHED THEN UPDATE SET
         CompanyName = s.CompanyName, ContactName = s.ContactName, ContactTitle = s.ContactTitle,
         City = s.City, Region = s.Region, PostalCode = s.PostalCode, Country = s.Country
    WHEN NOT MATCHED BY TARGET THEN
         INSERT (CustomerID, CompanyName, ContactName, ContactTitle, City, Region, PostalCode, Country)
         VALUES (s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle, s.City, s.Region, s.PostalCode, s.Country);
END
