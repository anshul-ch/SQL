-- Procedures to implement cursors


-- 1: Create database

-- IF DB_ID('cursorDB') IS NULL
-- BEGIN
--     CREATE DATABASE cursorDB;
-- END;
-- GO

-- USE cursorDB;
-- GO

--2 Create Tables + Sample Data
-- IF OBJECT_ID('dbo.usp_Setup_Tables','P') IS NOT NULL
--     DROP PROCEDURE dbo.usp_Setup_Tables;
-- GO

-- CREATE PROCEDURE dbo.usp_Setup_Tables
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     IF OBJECT_ID('dbo.Products','U') IS NOT NULL DROP TABLE dbo.Products;

--     CREATE TABLE dbo.Products
--     (
--         ProductId INT IDENTITY PRIMARY KEY,
--         ProductName VARCHAR(100) NOT NULL,
--         Category VARCHAR(50) NOT NULL,
--         Price DECIMAL(10,2) CHECK (Price > 0),
--         StockQty INT CHECK (StockQty >= 0),
--         IsActive BIT DEFAULT 1,
--         CreatedAt DATETIME2 DEFAULT SYSDATETIME()
--     );

--     INSERT INTO dbo.Products(ProductName, Category, Price, StockQty)
--     VALUES
--     ('Wireless Mouse','Electronics',799,50),
--     ('Mechanical Keyboard','Electronics',2499,25),
--     ('Running Shoes','Fashion',1899,40),
--     ('Water Bottle','Fitness',399,120),
--     ('Laptop Backpack','Accessories',1499,35),
--     ('USB-C Cable','Electronics',299,15),
--     ('Gym Gloves','Fitness',499,28);
-- END;
-- GO

-- EXEC dbo.usp_Setup_Tables;
-- GO

-- 3. Beginner Cursor – Print Products
-- IF OBJECT_ID('dbo.usp_Cursor_PrintProducts','P') IS NOT NULL
--     DROP PROCEDURE dbo.usp_Cursor_PrintProducts;
-- GO

-- CREATE PROCEDURE dbo.usp_Cursor_PrintProducts
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @Id INT, @Name VARCHAR(100), @Price DECIMAL(10,2);

--     DECLARE curProducts CURSOR FAST_FORWARD
--     FOR SELECT ProductId, ProductName, Price FROM dbo.Products ORDER BY ProductId;

--     OPEN curProducts;
--     FETCH NEXT FROM curProducts INTO @Id, @Name, @Price;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         PRINT 'ID=' + CAST(@Id AS VARCHAR) + ' | ' + @Name + ' | ' + CAST(@Price AS VARCHAR);
--         FETCH NEXT FROM curProducts INTO @Id, @Name, @Price;
--     END;

--     CLOSE curProducts;
--     DEALLOCATE curProducts;
-- END;
-- GO

-- EXEC dbo.usp_Cursor_PrintProducts;
-- GO


-- 4. Intermediate Cursor – Low Stock Reorder Log
-- IF OBJECT_ID('dbo.ReorderLog','U') IS NULL
-- CREATE TABLE dbo.ReorderLog
-- (
--     LogId INT IDENTITY PRIMARY KEY,
--     ProductId INT,
--     Message VARCHAR(200),
--     CreatedAt DATETIME2 DEFAULT SYSDATETIME()
-- );
-- GO

-- IF OBJECT_ID('dbo.usp_Cursor_ReorderLog','P') IS NOT NULL
--     DROP PROCEDURE dbo.usp_Cursor_ReorderLog;
-- GO

-- CREATE PROCEDURE dbo.usp_Cursor_ReorderLog
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     TRUNCATE TABLE dbo.ReorderLog;

--     DECLARE @Id INT, @Name VARCHAR(100), @Qty INT;

--     DECLARE curLowStock CURSOR FAST_FORWARD
--     FOR SELECT ProductId, ProductName, StockQty FROM dbo.Products WHERE StockQty < 30;

--     OPEN curLowStock;
--     FETCH NEXT FROM curLowStock INTO @Id, @Name, @Qty;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         INSERT INTO dbo.ReorderLog(ProductId, Message)
--         VALUES (@Id, 'Reorder needed for ' + @Name + ' (Stock=' + CAST(@Qty AS VARCHAR) + ')');

--         FETCH NEXT FROM curLowStock INTO @Id, @Name, @Qty;
--     END;

--     CLOSE curLowStock;
--     DEALLOCATE curLowStock;
-- END;
-- GO

-- EXEC dbo.usp_Cursor_ReorderLog;
-- GO

-- 5. Advanced Cursor – Price Increase with Transaction
-- IF OBJECT_ID('dbo.PriceChangeLog','U') IS NULL
-- CREATE TABLE dbo.PriceChangeLog
-- (
--     LogId INT IDENTITY PRIMARY KEY,
--     ProductId INT,
--     OldPrice DECIMAL(10,2),
--     NewPrice DECIMAL(10,2),
--     ChangedAt DATETIME2 DEFAULT SYSDATETIME()
-- );
-- GO

-- IF OBJECT_ID('dbo.usp_Cursor_FashionPriceIncrease','P') IS NOT NULL
--     DROP PROCEDURE dbo.usp_Cursor_FashionPriceIncrease;
-- GO

-- CREATE PROCEDURE dbo.usp_Cursor_FashionPriceIncrease
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @Id INT, @Old DECIMAL(10,2), @New DECIMAL(10,2);

--     DECLARE curFashion CURSOR FAST_FORWARD
--     FOR SELECT ProductId, Price FROM dbo.Products WHERE Category='Fashion';

--     BEGIN TRY
--         BEGIN TRAN;

--         OPEN curFashion;
--         FETCH NEXT FROM curFashion INTO @Id, @Old;

--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             SET @New = ROUND(@Old * 1.05, 2);

--             UPDATE dbo.Products SET Price=@New WHERE ProductId=@Id;

--             INSERT INTO dbo.PriceChangeLog(ProductId, OldPrice, NewPrice)
--             VALUES (@Id, @Old, @New);

--             FETCH NEXT FROM curFashion INTO @Id, @Old;
--         END;

--         CLOSE curFashion;
--         DEALLOCATE curFashion;
--         COMMIT TRAN;
--     END TRY
--     BEGIN CATCH
--         IF @@TRANCOUNT > 0 ROLLBACK;
--         THROW;
--     END CATCH;
-- END;
-- GO

-- EXEC dbo.usp_Cursor_FashionPriceIncrease;
-- GO


-- 6. Price Audit Trigger
-- CREATE OR ALTER TRIGGER dbo.trg_ProductPriceAudit
-- ON dbo.Products
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     INSERT INTO dbo.ProductPriceAudit(ProductId, OldPrice, NewPrice, ChangedBy)
--     SELECT i.ProductId, d.Price, i.Price, SUSER_SNAME()
--     FROM inserted i
--     JOIN deleted d ON i.ProductId=d.ProductId
--     WHERE i.Price<>d.Price;
-- END;
-- GO

-- 7. Stock Validation + Audit Trigger
-- CREATE OR ALTER TRIGGER dbo.trg_StockAudit_Validate
-- ON dbo.Products
-- AFTER UPDATE
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     IF EXISTS (SELECT 1 FROM inserted WHERE StockQty < 0)
--         THROW 51000,'StockQty cannot be negative',1;

--     INSERT INTO dbo.StockAudit(ProductId, OldStock, NewStock)
--     SELECT i.ProductId, d.StockQty, i.StockQty
--     FROM inserted i
--     JOIN deleted d ON i.ProductId=d.ProductId
--     WHERE i.StockQty<>d.StockQty;
-- END;
-- GO


-- 8. VIEW + INSTEAD OF TRIGGER
-- CREATE OR ALTER VIEW dbo.vw_ActiveProducts
-- AS
-- SELECT ProductName, Category, Price, StockQty
-- FROM dbo.Products
-- WHERE IsActive=1;
-- GO

-- CREATE OR ALTER TRIGGER dbo.trg_vw_ActiveProducts_Insert
-- ON dbo.vw_ActiveProducts
-- INSTEAD OF INSERT
-- AS
-- BEGIN
--     INSERT INTO dbo.Products(ProductName, Category, Price, StockQty, IsActive)
--     SELECT ProductName, Category, Price, StockQty, 1
--     FROM inserted;
-- END;
-- GO


-- Execution-order
-- EXEC dbo.usp_Setup_Tables;
-- EXEC dbo.usp_Cursor_PrintProducts;
-- EXEC dbo.usp_Cursor_ReorderLog;
-- EXEC dbo.usp_Cursor_FashionPriceIncrease;
