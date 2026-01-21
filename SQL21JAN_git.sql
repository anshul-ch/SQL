CREATE DATABASE Purchase;
GO
USE Purchase;
GO


-- Customers table
CREATE TABLE dbo.Customers
(
    CustomerId   INT PRIMARY KEY,
    FullName     VARCHAR(100) NOT NULL,
    City         VARCHAR(50)  NOT NULL,
    Segment      VARCHAR(20)  NOT NULL,   -- Retail / Corporate
    IsActive     BIT          NOT NULL,
    CreatedOn    DATE         NOT NULL
);
GO

-- Orders table
CREATE TABLE dbo.Orders
(
    OrderId      INT PRIMARY KEY,
    CustomerId   INT NOT NULL,
    OrderDate    DATE NOT NULL,
    Amount       DECIMAL(10,2) NOT NULL,
    Status       VARCHAR(20) NOT NULL,    -- Delivered/Cancelled/Pending
    PaymentMode  VARCHAR(20) NOT NULL,    -- UPI/Card/Cash
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);
GO

-- Insert Customers
INSERT INTO dbo.Customers (CustomerId, FullName, City, Segment, IsActive, CreatedOn) VALUES
(101, 'Gopi Suresh',   'Coimbatore', 'Retail',    1, '2025-11-12'),
(102, 'Anita Ravi',    'Chennai',    'Corporate', 1, '2025-10-05'),
(103, 'Karthik Mohan', 'Bengaluru',  'Retail',    1, '2025-09-15'),
(104, 'Meena Kumar',   'Chennai',    'Retail',    0, '2024-12-20'),
(105, 'Suresh Babu',   'Hyderabad',  'Corporate', 1, '2025-01-10');
GO

-- Insert Orders
INSERT INTO dbo.Orders (OrderId, CustomerId, OrderDate, Amount, Status, PaymentMode) VALUES
(5001, 101, '2026-01-10', 1200.00, 'Delivered', 'UPI'),
(5002, 101, '2026-01-15',  850.00, 'Pending',   'Card'),
(5003, 102, '2026-01-05', 5000.00, 'Delivered', 'Card'),
(5004, 103, '2025-12-30',  300.00, 'Cancelled', 'Cash'),
(5005, 105, '2026-01-18', 2500.00, 'Delivered', 'UPI'),
(5006, 102, '2026-01-20', 1500.00, 'Pending',   'UPI');
GO


-- SELECT COMMANDS (Data Retrival)
SELECT *
FROM dbo.Customers;

SELECT CustomerId, FullName, City
FROM dbo.Customers;

SELECT DISTINCT City
FROM dbo.Customers;

SELECT FullName AS CustomerName, City AS CustomerCity
FROM dbo.Customers;

SELECT *
FROM dbo.Customers
WHERE City = 'Chennai';

SELECT *
FROM dbo.Orders
WHERE Status = 'Delivered' AND PaymentMode = 'UPI';


SELECT *
FROM dbo.Customers
WHERE City IN ('Chennai', 'Coimbatore');

SELECT *
FROM dbo.Orders
WHERE Amount BETWEEN 800 AND 3000;


SELECT *
FROM dbo.Customers
WHERE FullName LIKE 'S%';

SELECT *
FROM dbo.Orders
ORDER BY Amount DESC;

SELECT TOP 3 *
FROM dbo.Orders
ORDER BY Amount DESC;

SELECT TOP 3 *
FROM dbo.Orders
ORDER BY Amount DESC;
GO

-- Aggregate functions
SELECT Status, COUNT(*) AS TotalOrders, SUM(Amount) AS TotalAmount
FROM dbo.Orders
GROUP BY Status;

SELECT Status, COUNT(*) AS TotalOrders, SUM(Amount) AS TotalAmount
FROM dbo.Orders
GROUP BY Status;
GO

-- JOINS
SELECT c.FullName, o.OrderId, o.Amount, o.Status
FROM dbo.Customers c
INNER JOIN dbo.Orders o ON c.CustomerId = o.CustomerId;

SELECT c.FullName, o.OrderId, o.Status
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON c.CustomerId = o.CustomerId;

SELECT *
FROM dbo.Customers
WHERE CustomerId IN (
    SELECT CustomerId
    FROM dbo.Orders
    WHERE Status = 'Delivered'
);

SELECT OrderId, Amount,
       CASE 
           WHEN Amount >= 3000 THEN 'High'
           WHEN Amount >= 1000 THEN 'Medium'
           ELSE 'Low'
       END AS OrderSize
FROM dbo.Orders;


SELECT c.CustomerId, c.FullName
FROM dbo.Customers c
WHERE EXISTS (
    SELECT 1
    FROM dbo.Orders o
    WHERE o.CustomerId = c.CustomerId
      AND o.Status = 'Pending'
);

SELECT City FROM dbo.Customers WHERE City = 'Chennai'
UNION
SELECT City FROM dbo.Customers WHERE City = 'Coimbatore';

SELECT *
INTO dbo.DeliveredOrders
FROM dbo.Orders
WHERE Status = 'Delivered';

WITH BigOrders AS (
    SELECT OrderId, CustomerId, Amount
    FROM dbo.Orders
    WHERE Amount >= 2000
)
SELECT *
FROM BigOrders;
GO