/* ==========================================================
   01_create_database_dw.sql
   Crea la base NorthwindDW y los esquemas lógicos:
     dw  = dimensiones y hechos (capa de consumo)
     stg = staging (copia cruda del OLTP)
     etl = tablas de control del proceso de carga
   ========================================================== */
GO

IF DB_ID(N'NorthwindDW') IS NULL
BEGIN
    CREATE DATABASE [NorthwindDW];
END
GO

ALTER DATABASE [NorthwindDW] SET RECOVERY SIMPLE;              -- DW recargable: no requiere log completo
ALTER DATABASE [NorthwindDW] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE; -- lecturas sin bloqueo durante cargas
ALTER DATABASE [NorthwindDW] SET AUTO_UPDATE_STATISTICS ON;
GO

USE [NorthwindDW] ;
GO

IF SCHEMA_ID(N'dw')  IS NULL EXEC(N'CREATE SCHEMA [dw]  AUTHORIZATION [dbo]');
IF SCHEMA_ID(N'stg') IS NULL EXEC(N'CREATE SCHEMA [stg] AUTHORIZATION [dbo]');
IF SCHEMA_ID(N'etl') IS NULL EXEC(N'CREATE SCHEMA [etl] AUTHORIZATION [dbo]');
GO