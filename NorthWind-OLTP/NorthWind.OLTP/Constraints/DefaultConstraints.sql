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
