# Conexión a Power BI

1. Power BI Desktop → **Obtener datos → SQL Server** → servidor/instancia, base `NorthWindDW`, modo **Importar**.
2. Selecciona `dw.FactSales` y todas las `dw.Dim*`.
3. Relaciones (todas muchos-a-uno hacia la dimensión, dirección única):
   - `FactSales[OrderDateKey]` → `DimDate[DateKey]` (**activa**)
   - `FactSales[RequiredDateKey]` → `DimDate[DateKey]` (inactiva)
   - `FactSales[ShippedDateKey]` → `DimDate[DateKey]` (inactiva)
   - `CustomerKey`, `ProductKey`, `EmployeeKey`, `ShipperKey`, `ShipLocationKey` → su dimensión.
4. Marca `DimDate` como tabla de fechas (columna `FullDate`).

## Medidas DAX sugeridas
```DAX
Ventas Netas = SUM ( FactSales[SalesAmount] )
Unidades = SUM ( FactSales[Quantity] )
Pedidos = DISTINCTCOUNT ( FactSales[OrderID] )
Ticket Promedio = DIVIDE ( [Ventas Netas], [Pedidos] )
Descuento % = DIVIDE ( SUM ( FactSales[DiscountAmount] ), SUM ( FactSales[GrossAmount] ) )
Dias Promedio Envio = AVERAGE ( FactSales[DaysToShip] )
Ventas Año Anterior = CALCULATE ( [Ventas Netas], SAMEPERIODLASTYEAR ( DimDate[FullDate] ) )
Ventas por Fecha de Envio = CALCULATE ( [Ventas Netas], USERELATIONSHIP ( FactSales[ShippedDateKey], DimDate[DateKey] ) )
```

## Visualizaciones sugeridas
Tarjetas (Ventas Netas, Pedidos, Ticket Promedio) · Líneas de ventas por `YearMonth` · Barras por `CategoryName` · Top 10 productos · Mapa/barras por `ShipCountry` · Ventas por empleado.
