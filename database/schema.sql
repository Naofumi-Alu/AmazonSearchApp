-- Create a Database of Products from Amazon if it does not exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AmazonSearchApp')
BEGIN
    CREATE DATABASE AmazonSearchApp;
END
GO

-- Use the Database
USE AmazonSearchApp;
GO

-- Create a Table of Products
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'products' AND type = 'U')
BEGIN
    CREATE TABLE products (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        NameXPATH TEXT NOT NULL,
        PriceXPATH TEXT NOT NULL
    );
END
GO
