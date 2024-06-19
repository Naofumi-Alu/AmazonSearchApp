"Create a Database of Products from Amazon if does not exist"
CREATE DATABASE IF NOT EXISTS amazon_products;

"Use the Database"
USE amazon_products;

"Create a Table of Products"
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    NameXPATH TEXT NOT NULL,
    PriceXPATH TEXT NOT NULL,
);

