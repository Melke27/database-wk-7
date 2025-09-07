-- ===========================================
-- Assignment: Database Design and Normalization
-- Questions 1 & 2: Achieving 1NF and 2NF
-- ===========================================

-- ===========================================
-- Question 1: Achieving First Normal Form (1NF)
-- ===========================================

-- Step 1: Create the original ProductDetail table with multivalued column
DROP TABLE IF EXISTS ProductDetail;
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Step 2: Insert the sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 3: Transform the table into 1NF by splitting multivalued column
-- This uses a recursive CTE or a workaround depending on MySQL version
-- Below is a simple simulation using JOIN for up to 3 products per row

-- Output: Each row contains one product per order
WITH SplitProducts AS (
    SELECT 
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', numbers.n), ',', -1)) AS Product
    FROM 
        ProductDetail
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
    ) numbers
    ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= numbers.n - 1
)

SELECT * FROM SplitProducts
ORDER BY OrderID, Product;


-- ===========================================
-- Question 2: Achieving Second Normal Form (2NF)
-- ===========================================

-- Step 1: Create the original unnormalized OrderDetails table
DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

-- Step 2: Insert the given data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 3: Create the normalized 'Orders' table (removing partial dependency)
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 4: Create the normalized 'OrderItems' table
DROP TABLE IF EXISTS OrderItems;
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- ✅ Done: Data is now in 2NF
