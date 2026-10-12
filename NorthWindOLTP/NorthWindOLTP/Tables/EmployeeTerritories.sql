CREATE TABLE [dbo].[EmployeeTerritories](
	[EmployeeID] [int]			 NOT NULL,
	[TerritoryID] [nvarchar](20) NOT NULL,
	[rowversion] [timestamp]	 NULL,
 CONSTRAINT [PK_EmployeeTerritories] PRIMARY KEY  
(
	[EmployeeID] ASC,
	[TerritoryID] ASC
));