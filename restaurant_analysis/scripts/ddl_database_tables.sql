/*
    Database: Maven_RestaurantDB
    Purpose: Restaurant menu and order details analysis.
    Configuration: UTF-8 collation, SQL Server 2022 compatibility,
    and SIMPLE recovery model.
*/

IF DB_ID(N'Maven_RestaurantDB') IS NULL
BEGIN
    CREATE DATABASE Maven_RestaurantDB
        COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END;
GO

-- Configure database compatibility and recovery settings.
ALTER DATABASE Maven_RestaurantDB
    SET COMPATIBILITY_LEVEL = 160;
GO

ALTER DATABASE Maven_RestaurantDB
    SET RECOVERY SIMPLE;
GO

-- Switch to the project database before creating tables.
USE [Maven_RestaurantDB];
GO

/*
    Table: restaurant_db_data_dictionary
    Purpose: Store metadata and descriptions for database tables and columns.
*/
IF OBJECT_ID(N'dbo.restaurant_db_data_dictionary', N'U') IS NOT NULL
    DROP TABLE dbo.restaurant_db_data_dictionary;
GO

CREATE TABLE dbo.restaurant_db_data_dictionary (
    table_name    VARCHAR(100) NOT NULL,
    field_name    VARCHAR(100) NOT NULL,
    [description] VARCHAR(100) NOT NULL
);
GO

/*
    Table: menu_items
    Purpose: Store restaurant menu items, their categories, and prices.
    Primary Key: menu_items_id
    Unique Constraint: item_name
*/
IF OBJECT_ID(N'dbo.menu_items', N'U') IS NOT NULL
    DROP TABLE dbo.menu_items;
GO

CREATE TABLE dbo.menu_items (
    menu_items_id INT          NOT NULL,
    item_name     VARCHAR(50)  NOT NULL,
    category      VARCHAR(50)  NULL,
    price         DECIMAL(8,2) NULL,

    CONSTRAINT pk_menu_items
        PRIMARY KEY (menu_items_id),

    CONSTRAINT uq_menu_items_item_name
        UNIQUE (item_name)
);
GO

/*
    Table: order_details
    Purpose: Store individual order-detail records, including order
    identifiers, dates, times, and associated menu items.
    Primary Key: order_details_id
    Foreign Key: item_id references menu_items.menu_items_id
*/
IF OBJECT_ID(N'dbo.order_details', N'U') IS NOT NULL
    DROP TABLE dbo.order_details;
GO

CREATE TABLE dbo.order_details (
    order_details_id INT  NOT NULL,
    order_id         INT  NOT NULL,
    order_date       DATE NULL,
    order_time       TIME NULL,
    item_id          INT  NULL,

    CONSTRAINT pk_order_details
        PRIMARY KEY (order_details_id),

    CONSTRAINT fk_order_details_menu_items
        FOREIGN KEY (item_id)
        REFERENCES dbo.menu_items (menu_items_id)
);
GO
