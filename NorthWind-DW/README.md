# NorthWind DW – Modelo estrella (SQL Server)

Proyecto de base de datos del **data warehouse** `NorthWindDW`, desnormalizado a partir de la base OLTP **NorthWind** (repositorio hermano: NorthWind-OLTP).

## Integrantes
| Nombre | Rol | Correo / GitHub |
|---|---|---|
| _Completar_ | | |
| _Completar_ | | |
| _Completar_ | | |

## Modelo
Una tabla de hechos `dw.FactSales` (una fila por línea de pedido) y seis dimensiones: `DimDate`, `DimCustomer`, `DimProduct` (incluye categoría y proveedor), `DimEmployee`, `DimShipper`, `DimShipLocation`.
Detalle, diagrama y decisiones de diseño: [`Docs/ModeloEstrella.md`](Docs/ModeloEstrella.md).

## Estructura
```
NorthWind.DW/
├── Schemas/           dw (modelo) y etl (carga)
├── Tables/            6 dimensiones + 1 tabla de hechos
├── StoredProcedures/  ETL en T-SQL (usp_Load_*, usp_Load_All, usp_Validate)
└── NorthWind.DW.sqlproj
Deploy/NorthWind_DW_Full.sql     script único listo para SSMS
Docs/                            modelo estrella y guía de Power BI
```

## Orden de ejecución
1. Desplegar `NorthWind` (repo OLTP) y asegurarse de que tiene datos.
2. Ejecutar `Deploy/NorthWind_DW_Full.sql` (crea `NorthWindDW`, tablas y procedimientos).
3. Cargar: `EXEC etl.usp_Load_All;`
4. Validar: `EXEC etl.usp_Validate;` → todas las filas deben decir `OK`.
5. Conectar Power BI según [`Docs/PowerBI.md`](Docs/PowerBI.md).

`usp_Load_All` carga primero las dimensiones y al final los hechos, dentro de una transacción. Los procedimientos leen la base origen con nombres de tres partes (`[NorthWind].[dbo].[...]`), por lo que ambas bases deben estar en la **misma instancia**.

## ETL con SSIS (opcional)
Si el curso exige SSIS, crea un proyecto *Integration Services* con una tarea **Execute SQL Task** por cada `etl.usp_Load_*` en el mismo orden (dimensiones → `usp_Load_FactSales`), o una sola que ejecute `etl.usp_Load_All`.
