/*
Script de implementación para prueba

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "prueba"
:setvar DefaultFilePrefix "prueba"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detecte el modo SQLCMD y deshabilite la ejecución de scripts si no se admite el modo SQLCMD.
Para volver a habilitar el script después de habilitar el modo SQLCMD, ejecute lo siguiente:
ESTABLECER NOEXEC DESACTIVADO; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_Discount]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_Discount] DEFAULT ((0)) FOR [Discount];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_Quantity]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_Quantity] DEFAULT ((1)) FOR [Quantity];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Order_Details_UnitPrice]...';


GO
ALTER TABLE [dbo].[OrderDetails]
    ADD CONSTRAINT [DF_Order_Details_UnitPrice] DEFAULT ((0)) FOR [UnitPrice];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Orders_Freight]...';


GO
ALTER TABLE [dbo].[Orders]
    ADD CONSTRAINT [DF_Orders_Freight] DEFAULT ((0)) FOR [Freight];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_Discontinued]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_Discontinued] DEFAULT ((0)) FOR [Discontinued];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_ReorderLevel]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_ReorderLevel] DEFAULT ((0)) FOR [ReorderLevel];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitPrice]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitPrice] DEFAULT ((0)) FOR [UnitPrice];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitsInStock]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitsInStock] DEFAULT ((0)) FOR [UnitsInStock];


GO
PRINT N'Creando Restricción DEFAULT [dbo].[DF_Products_UnitsOnOrder]...';


GO
ALTER TABLE [dbo].[Products]
    ADD CONSTRAINT [DF_Products_UnitsOnOrder] DEFAULT ((0)) FOR [UnitsOnOrder];


GO
PRINT N'Creando Clave externa [dbo].[FK_CustomerCustomerDemo]...';


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH NOCHECK
    ADD CONSTRAINT [FK_CustomerCustomerDemo] FOREIGN KEY ([CustomerTypeID]) REFERENCES [dbo].[CustomerDemographics] ([CustomerTypeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_CustomerCustomerDemo_Customers]...';


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH NOCHECK
    ADD CONSTRAINT [FK_CustomerCustomerDemo_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Employees_Employees]...';


GO
ALTER TABLE [dbo].[Employees] WITH NOCHECK
    ADD CONSTRAINT [FK_Employees_Employees] FOREIGN KEY ([ReportsTo]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_EmployeeTerritories_Employees]...';


GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH NOCHECK
    ADD CONSTRAINT [FK_EmployeeTerritories_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_EmployeeTerritories_Territories]...';


GO
ALTER TABLE [dbo].[EmployeeTerritories] WITH NOCHECK
    ADD CONSTRAINT [FK_EmployeeTerritories_Territories] FOREIGN KEY ([TerritoryID]) REFERENCES [dbo].[Territories] ([TerritoryID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Order_Details_Orders]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_Order_Details_Orders] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders] ([OrderID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Order_Details_Products]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_Order_Details_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products] ([ProductID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Customers]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Employees]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Employees] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employees] ([EmployeeID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Orders_Shippers]...';


GO
ALTER TABLE [dbo].[Orders] WITH NOCHECK
    ADD CONSTRAINT [FK_Orders_Shippers] FOREIGN KEY ([ShipVia]) REFERENCES [dbo].[Shippers] ([ShipperID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Products_Categories]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Products_Suppliers]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [FK_Products_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID]);


GO
PRINT N'Creando Clave externa [dbo].[FK_Territories_Region]...';


GO
ALTER TABLE [dbo].[Territories] WITH NOCHECK
    ADD CONSTRAINT [FK_Territories_Region] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Region] ([RegionID]);


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Birthdate]...';


GO
ALTER TABLE [dbo].[Employees] WITH NOCHECK
    ADD CONSTRAINT [CK_Birthdate] CHECK (([BirthDate]<getdate()));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Discount]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_Discount] CHECK (([Discount]>=(0) AND [Discount]<=(1)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Quantity]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_Quantity] CHECK (([Quantity]>(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitPrice]...';


GO
ALTER TABLE [dbo].[OrderDetails] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitPrice] CHECK (([UnitPrice]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_Products_UnitPrice]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_Products_UnitPrice] CHECK (([UnitPrice]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_ReorderLevel]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_ReorderLevel] CHECK (([ReorderLevel]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitsInStock]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitsInStock] CHECK (([UnitsInStock]>=(0)));


GO
PRINT N'Creando Restricción CHECK [dbo].[CK_UnitsOnOrder]...';


GO
ALTER TABLE [dbo].[Products] WITH NOCHECK
    ADD CONSTRAINT [CK_UnitsOnOrder] CHECK (([UnitsOnOrder]>=(0)));


GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK CHECK CONSTRAINT [FK_CustomerCustomerDemo];

ALTER TABLE [dbo].[CustomerCustomerDemo] WITH CHECK CHECK CONSTRAINT [FK_CustomerCustomerDemo_Customers];

ALTER TABLE [dbo].[Employees] WITH CHECK CHECK CONSTRAINT [FK_Employees_Employees];

ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK CHECK CONSTRAINT [FK_EmployeeTerritories_Employees];

ALTER TABLE [dbo].[EmployeeTerritories] WITH CHECK CHECK CONSTRAINT [FK_EmployeeTerritories_Territories];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [FK_Order_Details_Orders];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [FK_Order_Details_Products];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Customers];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Employees];

ALTER TABLE [dbo].[Orders] WITH CHECK CHECK CONSTRAINT [FK_Orders_Shippers];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [FK_Products_Categories];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [FK_Products_Suppliers];

ALTER TABLE [dbo].[Territories] WITH CHECK CHECK CONSTRAINT [FK_Territories_Region];

ALTER TABLE [dbo].[Employees] WITH CHECK CHECK CONSTRAINT [CK_Birthdate];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_Discount];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_Quantity];

ALTER TABLE [dbo].[OrderDetails] WITH CHECK CHECK CONSTRAINT [CK_UnitPrice];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_Products_UnitPrice];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_ReorderLevel];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_UnitsInStock];

ALTER TABLE [dbo].[Products] WITH CHECK CHECK CONSTRAINT [CK_UnitsOnOrder];


GO
PRINT N'Actualización completada.';


GO
