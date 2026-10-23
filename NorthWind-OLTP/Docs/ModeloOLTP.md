# Modelo OLTP NorthWind (13 tablas)

```mermaid
erDiagram
    Customers ||--o{ Orders : realiza
    Employees ||--o{ Orders : atiende
    Shippers  ||--o{ Orders : "envia (ShipVia)"
    Orders    ||--|{ OrderDetails : contiene
    Products  ||--o{ OrderDetails : "se vende en"
    Categories ||--o{ Products : clasifica
    Suppliers  ||--o{ Products : suministra
    Employees  ||--o{ Employees : "ReportsTo"
    Employees  ||--o{ EmployeeTerritories : cubre
    Territories ||--o{ EmployeeTerritories : "es cubierto"
    Region ||--o{ Territories : agrupa
    Customers ||--o{ CustomerCustomerDemo : tiene
    CustomerDemographics ||--o{ CustomerCustomerDemo : describe
```

**Por qué es OLTP:** esquema normalizado con llaves primarias/foráneas, tablas de catálogo (Categories, Shippers, Region...) separadas de las transaccionales (Orders, OrderDetails), restricciones CHECK/DEFAULT y columnas `rowversion` para control de cambios.
