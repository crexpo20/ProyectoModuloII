# Tarea 1.7: Creación de un Depósito de Datos - Northwind

## 👥 Integrantes del Grupo
* CORIMAYO COLMENARES EDGAR ARIEL
* CRESPO MONTAÑO MAURICIO OSCAR
* FERNANDEZ LOPEZ ERICK SAUL
* MELGAREJO CARDOZO RONALDO PABLO

---

## 📌 Descripción del Proyecto
Este repositorio contiene la solución a la tarea de implementación de una base de datos OLTP y la creación de un depósito de datos (Modelo Estrella - OLAP) utilizando la base de datos de ejemplo **Northwind**.

---

## 📁 Estructura del Repositorio

* **`NorthWinndOLTP/`**:
  * `01_Northwind_OLTP.sql`: Script completo con la estructura y datos de la base de datos transaccional original.

* **`NorthWindBI/`**:
  * `01_Crear_Modelo_Estrella.sql`: Script DDL para la creación de las tablas de dimensiones (`Dim_Cliente`, `Dim_Producto`, `Dim_Empleado`, `Dim_Tiempo`) y la tabla de hechos (`Fact_Ventas`).
  * `02_Poblar_Modelo_Estrella.sql`: Script DML/ETL para la extracción, transformación y carga de los datos desde la base OLTP hacia el modelo estrella.