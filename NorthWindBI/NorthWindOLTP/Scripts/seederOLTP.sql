/* ==========================================================
   00_seed_oltp_data.sql
   Datos de ejemplo (sintéticos) para el OLTP Northwind:
     8 categorías | 10 proveedores | 3 transportistas | 6 empleados
     30 clientes  | 40 productos   | 830 pedidos (jul-1996 a may-1998)
     ~2.500 líneas de pedido (1 a 5 por pedido)

   - Es determinista: cada ejecución sobre una base vacía genera los mismos datos
   - No inserta la columna [rowversion] (se genera sola)
   - Si el OLTP ya tiene datos, se detiene sin tocar nada

   ANTES DE EJECUTAR: cambiar el USE por el nombre de tu base OLTP.
   ========================================================== */
USE [nuevo]; 
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM dbo.Orders) OR EXISTS (SELECT 1 FROM dbo.Customers) OR EXISTS (SELECT 1 FROM dbo.Products)
    THROW 50000, N'El OLTP ya tiene datos. Para recargar, vacie las tablas primero (ver bloque comentado al final).', 1;

BEGIN TRAN;

/* ---------- Categories ---------- */
INSERT dbo.Categories (CategoryName, Description)
VALUES (N'Bebidas',         N'Jugos, cafes, tes, cervezas y licores'),
       (N'Condimentos',     N'Salsas, pastas, aderezos y aceites'),
       (N'Confiteria',      N'Chocolates, dulces y postres'),
       (N'Lacteos',         N'Quesos, yogures y mantequillas'),
       (N'Granos/Cereales', N'Granos, harinas, pastas y galletas'),
       (N'Carnes y Aves',   N'Carnes, embutidos y aves preparadas'),
       (N'Frescos',         N'Frutas secas, tuberculos y productos vegetales'),
       (N'Mariscos',        N'Pescados y mariscos frescos, ahumados y en conserva');

/* ---------- Suppliers ---------- */
INSERT dbo.Suppliers (CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, HomePage)
SELECT v.Company, v.Contact, v.Title,
       N'Zona Industrial #' + CAST(v.No * 10 AS nvarchar(10)),
       v.City, NULL, NULL, v.Country,
       N'555-' + RIGHT(N'0000' + CAST(v.No * 111 AS nvarchar(4)), 4), NULL, NULL
FROM (VALUES
    (1,  N'Andina Bebidas SRL',        N'Marcela Rojas',     N'Gerente de Compras', N'Santa Cruz',   N'Bolivia'),
    (2,  N'Sabores del Chaco',         N'Hector Vaca',       N'Gerente General',    N'Tarija',       N'Bolivia'),
    (3,  N'Dulces La Abuela',          N'Teresa Pinto',      N'Propietaria',        N'Cochabamba',   N'Bolivia'),
    (4,  N'Lacteos Valle Grande',      N'Raul Camacho',      N'Director Comercial', N'Santa Cruz',   N'Bolivia'),
    (5,  N'Granos del Altiplano',      N'Juana Condori',     N'Gerente de Ventas',  N'La Paz',       N'Bolivia'),
    (6,  N'Carnes Premium SA',         N'Mario Salvatierra', N'Jefe de Ventas',     N'Santa Cruz',   N'Bolivia'),
    (7,  N'Frutas y Verduras Sur',     N'Silvia Landivar',   N'Administradora',     N'Buenos Aires', N'Argentina'),
    (8,  N'Mariscos del Pacifico',     N'Cristian Aguilera', N'Gerente General',    N'Lima',         N'Peru'),
    (9,  N'Aceites Mediterraneos',     N'Pablo Ortega',      N'Director Comercial', N'Barcelona',    N'Espana'),
    (10, N'Import Export Americas',    N'Nora Daza',         N'Gerente de Compras', N'Miami',        N'USA')
) v(No, Company, Contact, Title, City, Country);

/* ---------- Shippers ---------- */
INSERT dbo.Shippers (CompanyName, Phone)
VALUES (N'Rapido Express',    N'(591) 3-555-0101'),
       (N'Cargo Andino',      N'(591) 2-555-0202'),
       (N'Transporte Global', N'(591) 4-555-0303');

/* ---------- Employees ---------- */
INSERT dbo.Employees (LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, Notes, PhotoPath)
VALUES (N'Mendoza',   N'Carlos',  N'Gerente de Ventas',  N'Sr.',   '1962-03-12', '1992-05-01', N'Av. Equipetrol 450',   N'Santa Cruz', N'SC', NULL, N'Bolivia', N'3-555-0101', N'1001', N'Gerente comercial.',  NULL),
       (N'Suarez',    N'Andrea',  N'Vendedora Senior',   N'Sra.',  '1966-07-25', '1993-08-17', N'Calle Beni 120',       N'Santa Cruz', N'SC', NULL, N'Bolivia', N'3-555-0102', N'1002', N'Vendedora senior.',  NULL),
       (N'Rivero',    N'Daniel',  N'Vendedor',           N'Sr.',   '1968-11-02', '1993-10-17', N'Av. San Martin 88',    N'Santa Cruz', N'SC', NULL, N'Bolivia', N'3-555-0103', N'1003', NULL,                  NULL),
       (N'Gutierrez', N'Paola',   N'Vendedora',          N'Srta.', '1970-04-18', '1994-03-05', N'Calle Sucre 305',      N'Cochabamba', N'CB', NULL, N'Bolivia', N'4-555-0104', N'1004', NULL,                  NULL),
       (N'Salazar',   N'Marcelo', N'Vendedor',           N'Sr.',   '1965-09-30', '1994-11-15', N'Av. Arce 1500',        N'La Paz',     N'LP', NULL, N'Bolivia', N'2-555-0105', N'1005', NULL,                  NULL),
       (N'Peredo',    N'Lucia',   N'Asistente de Ventas', N'Srta.', '1972-01-14', '1995-01-02', N'Calle Warnes 77',      N'Santa Cruz', N'SC', NULL, N'Bolivia', N'3-555-0106', N'1006', NULL,                  NULL);

-- Jerarquía (se resuelve por apellido para no depender de los IDs generados)
UPDATE e SET ReportsTo = m.EmployeeID
FROM dbo.Employees e
JOIN dbo.Employees m ON m.LastName = CASE e.LastName
                                         WHEN N'Suarez'    THEN N'Mendoza'
                                         WHEN N'Rivero'    THEN N'Suarez'
                                         WHEN N'Gutierrez' THEN N'Suarez'
                                         WHEN N'Salazar'   THEN N'Mendoza'
                                         WHEN N'Peredo'    THEN N'Mendoza'
                                     END;

/* ---------- Customers ---------- */
INSERT dbo.Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
SELECT v.ID, v.Company, v.Contact, v.Title,
       N'Av. Principal #' + CAST(v.No * 17 AS nvarchar(10)),
       v.City, NULL, NULL, v.Country,
       N'555-' + RIGHT(N'0000' + CAST(v.No * 137 AS nvarchar(4)), 4), NULL
FROM (VALUES
    (1,  N'ANDIN', N'Distribuidora Andina',      N'Rosa Quispe',        N'Gerente de Compras', N'La Paz',          N'Bolivia'),
    (2,  N'CRUCE', N'Supermercados Cruce',       N'Luis Suarez',        N'Jefe de Compras',    N'Santa Cruz',      N'Bolivia'),
    (3,  N'VALLE', N'Comercial El Valle',        N'Maria Torrico',      N'Propietaria',        N'Cochabamba',      N'Bolivia'),
    (4,  N'TARIJ', N'Vinos y Licores Tarija',    N'Pedro Arce',         N'Gerente General',    N'Tarija',          N'Bolivia'),
    (5,  N'SUCRE', N'Abarrotes Sucre',           N'Carla Montano',      N'Administradora',     N'Sucre',           N'Bolivia'),
    (6,  N'ORURO', N'Mercado Oruro SA',          N'Jose Mamani',        N'Jefe de Compras',    N'Oruro',           N'Bolivia'),
    (7,  N'BENIA', N'Amazonia Foods',            N'Elena Justiniano',   N'Gerente de Ventas',  N'Trinidad',        N'Bolivia'),
    (8,  N'PORTE', N'Almacenes del Puerto',      N'Ricardo Fuentes',    N'Gerente de Compras', N'Buenos Aires',    N'Argentina'),
    (9,  N'PAMPA', N'La Pampa Gourmet',          N'Sofia Herrera',      N'Propietaria',        N'Cordoba',         N'Argentina'),
    (10, N'MENDO', N'Bodega Mendoza',            N'Diego Morales',      N'Director Comercial', N'Mendoza',         N'Argentina'),
    (11, N'ROSAR', N'Rosario Distribuciones',    N'Lucia Ferrari',      N'Jefa de Compras',    N'Rosario',         N'Argentina'),
    (12, N'ANDES', N'Importadora Los Andes',     N'Camila Rojas',       N'Gerente de Compras', N'Santiago',        N'Chile'),
    (13, N'VALPA', N'Mercado Valparaiso',        N'Felipe Soto',        N'Propietario',        N'Valparaiso',      N'Chile'),
    (14, N'CONCE', N'Alimentos Concepcion',      N'Daniela Vera',       N'Administradora',     N'Concepcion',      N'Chile'),
    (15, N'LIMAS', N'Delicias de Lima',          N'Jorge Paredes',      N'Gerente General',    N'Lima',            N'Peru'),
    (16, N'CUSCO', N'Productos de Cusco',        N'Ana Huaman',         N'Jefa de Ventas',     N'Cusco',           N'Peru'),
    (17, N'AREQU', N'Arequipa Trading',          N'Miguel Flores',      N'Gerente de Compras', N'Arequipa',        N'Peru'),
    (18, N'PAULO', N'Sabores de Sao Paulo',      N'Carlos Almeida',     N'Director Comercial', N'Sao Paulo',       N'Brasil'),
    (19, N'RIOJA', N'Rio Alimentos',             N'Fernanda Costa',     N'Gerente de Compras', N'Rio de Janeiro',  N'Brasil'),
    (20, N'CURIT', N'Mercado Curitiba',          N'Rafael Lima',        N'Propietario',        N'Curitiba',        N'Brasil'),
    (21, N'MEXDF', N'Abarrotes Mexico',          N'Alejandro Ruiz',     N'Gerente de Compras', N'Mexico DF',       N'Mexico'),
    (22, N'GUADA', N'Distribuidora Guadalajara', N'Patricia Navarro',   N'Jefa de Compras',    N'Guadalajara',     N'Mexico'),
    (23, N'BOGOT', N'Comestibles Bogota',        N'Andres Castillo',    N'Gerente General',    N'Bogota',          N'Colombia'),
    (24, N'MEDEL', N'Sabores de Medellin',       N'Valentina Rios',     N'Administradora',     N'Medellin',        N'Colombia'),
    (25, N'QUITO', N'Mercado de Quito',          N'Santiago Villacis',  N'Gerente de Compras', N'Quito',           N'Ecuador'),
    (26, N'MONTE', N'Montevideo Foods',          N'Gabriela Pereira',   N'Directora Comercial',N'Montevideo',      N'Uruguay'),
    (27, N'ASUNC', N'Asuncion Mayorista',        N'Oscar Benitez',      N'Jefe de Compras',    N'Asuncion',        N'Paraguay'),
    (28, N'MADRI', N'Delicatessen Madrid',       N'Isabel Garcia',      N'Propietaria',        N'Madrid',          N'Espana'),
    (29, N'BARCE', N'Mercat Barcelona',          N'Jordi Puig',         N'Gerente de Compras', N'Barcelona',       N'Espana'),
    (30, N'MIAMI', N'Latin Market Miami',        N'Laura Mendez',       N'Purchasing Manager', N'Miami',           N'USA')
) v(No, ID, Company, Contact, Title, City, Country);

/* ---------- Products (proveedor asignado en rotación) ---------- */
INSERT dbo.Products (ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
SELECT p.Name, s.SupplierID, c.CategoryID, p.Qty, p.Price, p.Stock, p.OnOrder, p.Reorder, p.Disc
FROM (VALUES
    (1,  N'Jugo de Tumbo 1L',            N'Bebidas',         N'12 botellas x 1L',   18.00,  39,  0, 10, 0),
    (2,  N'Cafe Yungas 500g',            N'Bebidas',         N'24 bolsas x 500g',   24.50,  17, 40, 25, 0),
    (3,  N'Te de Coca (caja 20)',        N'Bebidas',         N'48 cajas',            9.80, 120,  0, 30, 0),
    (4,  N'Cerveza Artesanal 330ml',     N'Bebidas',         N'24 botellas x 330ml', 32.00,  52,  0, 20, 0),
    (5,  N'Singani Reserva 750ml',       N'Bebidas',         N'12 botellas x 750ml', 85.00,  14,  0, 15, 0),
    (6,  N'Salsa de Locoto 250ml',       N'Condimentos',     N'12 frascos x 250ml', 12.00,  76,  0, 15, 0),
    (7,  N'Aji Amarillo en Pasta',       N'Condimentos',     N'24 frascos x 200g',  14.75,  04, 70, 20, 0),
    (8,  N'Chimichurri Casero 200g',     N'Condimentos',     N'24 frascos x 200g',  11.20,  39,  0,  5, 0),
    (9,  N'Aceite de Oliva 500ml',       N'Condimentos',     N'12 botellas x 500ml',38.00,  29,  0,  0, 0),
    (10, N'Mostaza Dijon 300g',          N'Condimentos',     N'12 frascos x 300g',  16.40, 113,  0, 25, 1),
    (11, N'Chocolate Amargo 70%',        N'Confiteria',      N'30 barras x 100g',   21.00,  15, 60, 25, 0),
    (12, N'Alfajores Surtidos x12',      N'Confiteria',      N'12 cajas x 12 un.',  19.50,  62,  0,  0, 0),
    (13, N'Dulce de Leche 400g',         N'Confiteria',      N'24 frascos x 400g',  13.90,  09, 20, 10, 0),
    (14, N'Caramelos de Miel x50',       N'Confiteria',      N'60 bolsas x 50 un.',  7.30,  25,  0,  0, 0),
    (15, N'Turron de Mani 250g',         N'Confiteria',      N'40 cajas x 250g',    10.60,  88,  0, 10, 0),
    (16, N'Queso Chaqueno 1kg',          N'Lacteos',         N'10 piezas x 1kg',    43.00,  22,  0, 15, 0),
    (17, N'Queso Mozzarella 500g',       N'Lacteos',         N'20 paquetes x 500g', 27.50,  86,  0, 10, 0),
    (18, N'Yogur Natural 1L',            N'Lacteos',         N'12 botellas x 1L',    9.20,  50, 30, 20, 0),
    (19, N'Mantequilla 250g',            N'Lacteos',         N'40 barras x 250g',   15.30,  36,  0, 10, 0),
    (20, N'Queso Cuajada 400g',          N'Lacteos',         N'12 bandejas x 400g', 12.80,  07,  0,  5, 1),
    (21, N'Quinua Real 1kg',             N'Granos/Cereales', N'20 bolsas x 1kg',    22.00,  61,  0, 20, 0),
    (22, N'Arroz Grano Largo 5kg',       N'Granos/Cereales', N'10 bolsas x 5kg',    35.00, 104,  0, 30, 0),
    (23, N'Harina de Trigo 1kg',         N'Granos/Cereales', N'30 bolsas x 1kg',     6.50,  27, 10, 15, 0),
    (24, N'Fideos Spaghetti 500g',       N'Granos/Cereales', N'24 paquetes x 500g',  5.40,  41,  0, 10, 0),
    (25, N'Galletas Integrales x12',     N'Granos/Cereales', N'12 cajas x 12 un.',   8.90,  18,  0,  0, 0),
    (26, N'Charque de Llama 500g',       N'Carnes y Aves',   N'20 bolsas x 500g',   46.00,  05, 40, 20, 0),
    (27, N'Salchicha Parrillera 1kg',    N'Carnes y Aves',   N'10 paquetes x 1kg',  29.00,  35,  0, 10, 0),
    (28, N'Jamon Cocido 500g',           N'Carnes y Aves',   N'20 paquetes x 500g', 24.00,  79,  0,  0, 0),
    (29, N'Chorizo Criollo 1kg',         N'Carnes y Aves',   N'12 paquetes x 1kg',  37.50,  21,  0, 10, 1),
    (30, N'Pollo Ahumado 1kg',           N'Carnes y Aves',   N'10 piezas x 1kg',    33.00,  53,  0, 15, 0),
    (31, N'Platano Deshidratado 250g',   N'Frescos',         N'30 bolsas x 250g',    8.50,  32,  0,  0, 0),
    (32, N'Mix de Frutos Secos 500g',    N'Frescos',         N'24 bolsas x 500g',   26.00,  64,  0, 20, 0),
    (33, N'Tofu Organico 400g',          N'Frescos',         N'24 paquetes x 400g', 14.00,  35,  0,  5, 0),
    (34, N'Papa Deshidratada 1kg',       N'Frescos',         N'20 bolsas x 1kg',    12.30,  39,  0, 15, 0),
    (35, N'Chuno Tunta 1kg',             N'Frescos',         N'20 bolsas x 1kg',    11.00,  15, 25, 10, 0),
    (36, N'Pacu Ahumado 500g',           N'Mariscos',        N'12 paquetes x 500g', 31.00,  42,  0, 10, 0),
    (37, N'Atun en Lata x12',            N'Mariscos',        N'12 cajas x 12 un.',  48.00,  57,  0, 20, 0),
    (38, N'Surubi Congelado 1kg',        N'Mariscos',        N'10 bolsas x 1kg',    39.50,  06, 15, 10, 0),
    (39, N'Camarones Pelados 500g',      N'Mariscos',        N'20 bolsas x 500g',   52.00,  23,  0,  5, 0),
    (40, N'Sardinas en Aceite x24',      N'Mariscos',        N'24 latas',           18.80,  70,  0, 15, 1)
) p(No, Name, Category, Qty, Price, Stock, OnOrder, Reorder, Disc)
JOIN (SELECT SupplierID, ROW_NUMBER() OVER (ORDER BY SupplierID) AS rn FROM dbo.Suppliers) s
     ON s.rn = ((p.No - 1) % (SELECT COUNT(*) FROM dbo.Suppliers)) + 1
JOIN dbo.Categories c ON c.CategoryName = p.Category
ORDER BY p.No;

/* ---------- Tablas auxiliares para generar pedidos ---------- */
DROP TABLE IF EXISTS #cust, #emp, #ship, #prod;

SELECT ROW_NUMBER() OVER (ORDER BY CustomerID) AS rn, CustomerID, CompanyName, Address, City, Country
INTO #cust FROM dbo.Customers;
SELECT ROW_NUMBER() OVER (ORDER BY EmployeeID) AS rn, EmployeeID INTO #emp  FROM dbo.Employees;
SELECT ROW_NUMBER() OVER (ORDER BY ShipperID)  AS rn, ShipperID  INTO #ship FROM dbo.Shippers;
SELECT ROW_NUMBER() OVER (ORDER BY ProductID)  AS rn, ProductID, UnitPrice INTO #prod FROM dbo.Products;

DECLARE @nc int = (SELECT COUNT(*) FROM #cust),
        @ne int = (SELECT COUNT(*) FROM #emp),
        @ns int = (SELECT COUNT(*) FROM #ship),
        @np int = (SELECT COUNT(*) FROM #prod);   -- @np debe ser coprimo con 7 (con 40 productos lo es)

/* ---------- Orders: 830 pedidos, fechas crecientes con el ID ---------- */
;WITH N AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM N WHERE n < 830
)
INSERT dbo.Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight,
                   ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
SELECT c.CustomerID,
       e.EmployeeID,
       d.OrderDate,
       DATEADD(DAY, 14 + ABS(CHECKSUM(N.n, N'rq') % 15), d.OrderDate),
       CASE WHEN N.n > 805 THEN NULL                                   -- ultimos pedidos: aun sin enviar
            ELSE DATEADD(DAY, 1 + ABS(CHECKSUM(N.n, N'sh') % 24), d.OrderDate) END,
       s.ShipperID,
       CAST(5 + (ABS(CHECKSUM(N.n, N'fr') % 9500)) / 100.0 AS money),
       c.CompanyName, c.Address, c.City, NULL, NULL, c.Country
FROM N
CROSS APPLY (SELECT DATEADD(DAY, (N.n * 670) / 830, CAST('1996-07-04' AS datetime)) AS OrderDate) d
JOIN #cust c ON c.rn = 1 + ABS(CHECKSUM(N.n, N'cu') % @nc)
JOIN #emp  e ON e.rn = 1 + ABS(CHECKSUM(N.n, N'em') % @ne)
JOIN #ship s ON s.rn = 1 + ABS(CHECKSUM(N.n, N'sp') % @ns)
ORDER BY N.n
OPTION (MAXRECURSION 0);

/* ---------- OrderDetails: 1 a 5 líneas por pedido, sin productos repetidos ---------- */
;WITH O AS (
    SELECT OrderID, ROW_NUMBER() OVER (ORDER BY OrderID) AS n FROM dbo.Orders
),
K AS (
    SELECT 1 AS k UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
)
INSERT dbo.OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT O.OrderID,
       p.ProductID,
       p.UnitPrice,
       CAST(1 + ABS(CHECKSUM(O.n, K.k, N'q') % 40) AS smallint),
       CAST(CHOOSE(1 + ABS(CHECKSUM(O.n, K.k, N'd') % 6), 0, 0, 0, 0.05, 0.10, 0.15) AS real)
FROM O
JOIN K ON K.k <= 1 + ABS(CHECKSUM(O.n, N'ln') % 5)
JOIN #prod p ON p.rn = ((ABS(CHECKSUM(O.n, N'pb') % @np)) + (K.k - 1) * 7) % @np + 1;

DROP TABLE IF EXISTS #cust, #emp, #ship, #prod;

COMMIT TRAN;
GO

/* ==========================================================
   VERIFICACIÓN
   ========================================================== */
SELECT 'Categories' AS tabla, COUNT(*) AS filas FROM dbo.Categories
UNION ALL SELECT 'Suppliers',    COUNT(*) FROM dbo.Suppliers
UNION ALL SELECT 'Shippers',     COUNT(*) FROM dbo.Shippers
UNION ALL SELECT 'Employees',    COUNT(*) FROM dbo.Employees
UNION ALL SELECT 'Customers',    COUNT(*) FROM dbo.Customers
UNION ALL SELECT 'Products',     COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Orders',       COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderDetails', COUNT(*) FROM dbo.OrderDetails;

SELECT MIN(OrderDate) AS primer_pedido, MAX(OrderDate) AS ultimo_pedido,
       SUM(CASE WHEN ShippedDate IS NULL THEN 1 ELSE 0 END) AS sin_enviar
FROM dbo.Orders;
GO

/* ----------------------------------------------------------
   PARA RECARGAR DESDE CERO (descomentar y ejecutar antes de re-correr el script):

   TRUNCATE TABLE dbo.OrderDetails;
   TRUNCATE TABLE dbo.Orders;
   TRUNCATE TABLE dbo.Products;
   TRUNCATE TABLE dbo.Customers;
   TRUNCATE TABLE dbo.Employees;
   TRUNCATE TABLE dbo.Shippers;
   TRUNCATE TABLE dbo.Suppliers;
   TRUNCATE TABLE dbo.Categories;

   (Si el OLTP tiene claves foráneas, TRUNCATE fallará: use DELETE en el mismo orden
    y luego DBCC CHECKIDENT('dbo.<tabla>', RESEED, 0) para reiniciar los IDENTITY.)
   ---------------------------------------------------------- */