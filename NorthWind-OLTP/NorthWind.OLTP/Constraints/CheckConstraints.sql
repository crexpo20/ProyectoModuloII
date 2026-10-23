ALTER TABLE [dbo].[Employees] ADD CONSTRAINT [CK_Birthdate] CHECK (([BirthDate]<getdate()))
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_Discount] CHECK (([Discount]>=(0) AND [Discount]<=(1)))
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_Quantity] CHECK (([Quantity]>(0)))
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [CK_UnitPrice] CHECK (([UnitPrice]>=(0)))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_Products_UnitPrice] CHECK (([UnitPrice]>=(0)))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_ReorderLevel] CHECK (([ReorderLevel]>=(0)))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_UnitsInStock] CHECK (([UnitsInStock]>=(0)))
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [CK_UnitsOnOrder] CHECK (([UnitsOnOrder]>=(0)))
