/* Ejecutar primero en SSMS. Este archivo SOLO verifica la base OLTP restaurada. */
USE [NorthWind];
GO
SELECT DB_NAME() AS BaseActual;
SELECT COUNT(*) AS CantidadPedidos FROM dbo.Orders;
SELECT COUNT(*) AS CantidadDetalles FROM dbo.[OrderDetails];
SELECT TOP (10) OrderID, OrderDate, Freight FROM dbo.Orders ORDER BY OrderID;
GO
