-- Orquestador del ETL: orden correcto (dimensiones primero, hechos al final) dentro de una transaccion
CREATE PROCEDURE [etl].[usp_Load_All]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            EXEC [etl].[usp_Seed_UnknownMembers];
            EXEC [etl].[usp_Load_DimDate];
            EXEC [etl].[usp_Load_DimCustomer];
            EXEC [etl].[usp_Load_DimProduct];
            EXEC [etl].[usp_Load_DimEmployee];
            EXEC [etl].[usp_Load_DimShipper];
            EXEC [etl].[usp_Load_DimShipLocation];
            EXEC [etl].[usp_Load_FactSales];
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
