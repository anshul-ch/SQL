-- USE AdventureWorks2022;
-- GO

-- SELECT DB_NAME() AS CurrentDatabase;
-- GO

-- DROP TABLE IF EXISTS dbo.Person_Practice;
-- GO

-- SELECT TOP (20000)
--     BusinessEntityID,
--     FirstName,
--     LastName,
--     ModifiedDate
-- INTO dbo.Person_Practice
-- FROM Person.Person
-- ORDER BY BusinessEntityID;
-- GO

-- SELECT COUNT(*) AS [RowCount]
-- FROM dbo.Person_Practice;
-- GO

-- SET STATISTICS IO ON;
-- SET STATISTICS TIME ON;
-- GO

-- SELECT TOP 200
--     BusinessEntityID,
--     FirstName,
--     LastName
-- FROM dbo.Person_Practice
-- WHERE LastName = 'Smith'
-- ORDER BY FirstName;
-- GO

-- CREATE NONCLUSTERED INDEX IX_Person_Practice_LastName
-- ON dbo.Person_Practice(LastName);
-- GO

-- SELECT TOP 200
--     BusinessEntityID,
--     FirstName,
--     LastName
-- FROM dbo.Person_Practice
-- WHERE LastName = 'Smith'
-- ORDER BY FirstName;
-- GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


