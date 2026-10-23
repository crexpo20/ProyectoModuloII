-- Ejecutar estas consultas después de publicar el proyecto en NorthwindDW.
/*
SELECT s.name AS Esquema, t.name AS Tabla
FROM sys.tables AS t
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
ORDER BY t.name;
GO

SELECT OBJECT_NAME(fk.parent_object_id) AS TablaOrigen,
       fk.name AS NombreRelacion,
       OBJECT_NAME(fk.referenced_object_id) AS TablaDestino
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id = OBJECT_ID('dbo.FactVentas')
ORDER BY TablaDestino;
GO
*/