USE [Maven_RestaurantDB];
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '>> Deleting From Table: dbo.menu_items';
    Delete FROM dbo.menu_items;
    PRINT '>> Loading Table: dbo.menu_items';
    BULK INSERT dbo.menu_items
    FROM 'C:\Users\Mahdi\Documents\GitHub\maven-analytics-projects\restaurant_analysis\dataset\menu_items.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        TABLOCK
    );

    PRINT '>> Truncating Table: dbo.order_details';
    TRUNCATE TABLE dbo.order_details;
    PRINT '>> Loading Table: dbo.order_details';
    BULK INSERT dbo.order_details
    FROM 'C:\Users\Mahdi\Documents\GitHub\maven-analytics-projects\restaurant_analysis\dataset\order_details.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        TABLOCK
    );

    PRINT '>> Truncating Table: dbo.restaurant_db_data_dictionary';
    TRUNCATE TABLE dbo.restaurant_db_data_dictionary;
    PRINT '>> Loading Table: dbo.restaurant_db_data_dictionary';
    BULK INSERT dbo.restaurant_db_data_dictionary
    FROM 'C:\Users\Mahdi\Documents\GitHub\maven-analytics-projects\restaurant_analysis\dataset\restaurant_db_data_dictionary.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        TABLOCK
    );

    COMMIT TRANSACTION;
    PRINT '>> Data loading completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
