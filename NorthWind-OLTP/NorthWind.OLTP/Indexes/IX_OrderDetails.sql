CREATE NONCLUSTERED INDEX [OrderID] ON [dbo].[OrderDetails]
(
	[OrderID] ASC
)
GO

CREATE NONCLUSTERED INDEX [OrdersOrder_Details] ON [dbo].[OrderDetails]
(
	[OrderID] ASC
)
GO

CREATE NONCLUSTERED INDEX [ProductID] ON [dbo].[OrderDetails]
(
	[ProductID] ASC
)
GO

CREATE NONCLUSTERED INDEX [ProductsOrder_Details] ON [dbo].[OrderDetails]
(
	[ProductID] ASC
)
