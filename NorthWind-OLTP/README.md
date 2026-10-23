# NorthWind OLTP – Proyecto SQL Server

Proyecto de base de datos (SQL Server Database Project, estilo SDK `Microsoft.Build.Sql`) de la base transaccional **NorthWind**.
Forma parte del trabajo del diplomado en Ciencia de Datos. Repositorio hermano: **NorthWind-DW** (modelo estrella).

## Integrantes
| Nombre | Rol | Correo / GitHub |
|---|---|---|
| _Completar_ | | |
| _Completar_ | | |
| _Completar_ | | |

## Estructura
```
NorthWind.OLTP/
├── Tables/            13 tablas
├── Indexes/           índices no agrupados (uno por tabla)
├── Constraints/       DEFAULT, FOREIGN KEY y CHECK
├── Views/             16 vistas
├── StoredProcedures/  11 procedimientos
└── NorthWind.OLTP.sqlproj
Deploy/NorthWind_OLTP_Full.sql   script único listo para SSMS
Docs/ModeloOLTP.md               diagrama entidad-relación
```

## Cómo usarlo
**Opción A – SSMS (rápida):** abrir `Deploy/NorthWind_OLTP_Full.sql` y ejecutar. Es seguro ejecutarlo más de una vez:
- Si `NorthWind` **no existe**, la crea completa (tablas, índices, restricciones, vistas y procedimientos).
- Si `NorthWind` **ya existe**, no toca tablas ni datos; solo recrea vistas y procedimientos (`CREATE OR ALTER`).

**Opción A2 – Solo corregir vistas y procedimientos:** `Deploy/NorthWind_OLTP_Fix_Views_Procs.sql` (para una base que ya tiene datos).
**Opción B – Visual Studio / VS Code:** abrir `NorthWind.OLTP.sqlproj` → *Build* → *Publish* hacia tu instancia.

> El script original **no contiene datos** (solo estructura). Carga los datos de NorthWind antes de ejecutar el ETL del DW.

## Cambios respecto al script original
1. **Corrección de nombre:** la tabla se llama `OrderDetails`, pero vistas y procedimientos la referenciaban como `"Order Details"`, lo que hacía fallar el script. Todas las referencias se unificaron a `[OrderDetails]`.
2. Se quitaron las rutas físicas fijas de `CREATE DATABASE` (`C:\Program Files\...MSSQL17...`) para que funcione en cualquier instancia.
3. Se separó cada objeto en su propio archivo y se retiraron opciones de almacenamiento (`ON [PRIMARY]`, `PAD_INDEX`...) y sentencias `CHECK CONSTRAINT` que el proyecto SSDT no usa.

## Observación del código original (no modificada)
`GetCustomerChangesByRowVersion` une `CustomerDemographics` con `g.CustomerTypeID = g.CustomerTypeID` (probablemente debía ser `d.CustomerTypeID`).
