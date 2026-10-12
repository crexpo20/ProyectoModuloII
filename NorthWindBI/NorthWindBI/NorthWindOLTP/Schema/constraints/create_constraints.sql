
GO

-- DEFAULTs
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_UnitPrice] DEFAULT ((0)) FOR [UnitPrice]
GO
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_Quantity] DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_Order_Details_Discount] DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_Freight] DEFAULT ((0)) FOR [Freight]
GO
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitPrice] DEFAULT ((0)) FOR [UnitPrice]
GO
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitsInStock] DEFAULT ((0)) FOR [UnitsInStock]
GO
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_UnitsOnOrder] DEFAULT ((0)) FOR [UnitsOnOrder]
GO
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_ReorderLevel] DEFAULT ((0)) FOR [ReorderLevel]
GO
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_Discontinued] DEFAULT ((0)) FOR [Discontinued]
GO

-- FOREIGN KEYS
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK ADD CONSTRAINT [FK_CustomerCustomerDemo] FOREIGN KEY([CustomerTypeID]) REFERENCES [dbo].[CustomerDemographics] ([CustomerTypeID])
GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK ADD CONSTRAINT [FK_CustomerCustomerDemo_Customers] FOREIGN KEY([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Employees] WITH NOCHECK ADD CONSTRAINT [FK_Employees_Employees] FOREIGN KEY([ReportsTo]) REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK ADD CONSTRAINT [FK_EmployeeTerritories_Employees] FOREIGN KEY([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK ADD CONSTRAINT [FK_EmployeeTerritories_Territories] FOREIGN KEY([TerritoryID]) REFERENCES [dbo].[Territories] ([TerritoryID])
GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK ADD CONSTRAINT [FK_Order_Details_Orders] FOREIGN KEY([OrderID]) REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK ADD CONSTRAINT [FK_Order_Details_Products] FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK ADD CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK ADD CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK ADD CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY([ShipVia]) REFERENCES [dbo].[Shippers] ([ShipperID])
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [FK_Products_Suppliers] FOREIGN KEY([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[Territories] WITH CHECK ADD CONSTRAINT [FK_Territories_Region] FOREIGN KEY([RegionID]) REFERENCES [dbo].[Region] ([RegionID])
GO

-- CHECK CONSTRAINTS
ALTER TABLE [dbo].[Employees] WITH NOCHECK ADD CONSTRAINT [CK_Birthdate] CHECK (([BirthDate]<getdate()))
GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK ADD CONSTRAINT [CK_Discount] CHECK (([Discount]>=(0) AND [Discount]<=(1)))
GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK ADD CONSTRAINT [CK_Quantity] CHECK (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK ADD CONSTRAINT [CK_UnitPrice] CHECK (([UnitPrice]>=(0)))
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [CK_Products_UnitPrice] CHECK (([UnitPrice]>=(0)))
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [CK_ReorderLevel] CHECK (([ReorderLevel]>=(0)))
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [CK_UnitsInStock] CHECK (([UnitsInStock]>=(0)))
GO
ALTER TABLE [dbo].[Products] WITH NOCHECK ADD CONSTRAINT [CK_UnitsOnOrder] CHECK (([UnitsOnOrder]>=(0)))
GO