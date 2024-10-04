-- Issue 1: Some sales and profit values were stored as strings with currency symbols and commas.
-- We will convert them to decimal data types for consistency.
UPDATE Sales
SET Sales = CAST(REPLACE(REPLACE(Sales, '$', ''), ',', '') AS DECIMAL(10, 2))
WHERE Sales IS NOT NULL;

UPDATE Sales
SET Profit = CAST(REPLACE(REPLACE(Profit, '$', ''), ',', '') AS DECIMAL(10, 2))
WHERE Profit IS NOT NULL;

-- Issue 2: Shipping Mode had inconsistent naming (e.g., 'Regular Air', 'Regular Air Express', 'Express Air').
-- We will standardize them to 'Standard', 'Express', and 'Same Day'.
UPDATE Sales
SET ShipMode = 
    CASE 
        WHEN ShipMode LIKE '%Express%' THEN 'Express'
        WHEN ShipMode LIKE '%Same Day%' THEN 'Same Day'
        ELSE 'Standard'
    END;

-- Check for NULL values in key fields that should always have values.
SELECT COUNT(*) AS NullOrderIDs 
FROM Sales 
WHERE OrderID IS NULL;

SELECT COUNT(*) AS NullProductIDs 
FROM Sales 
WHERE ProductID IS NULL;

-- Identify any duplicate sales records based on OrderID and ProductID.
SELECT OrderID, ProductID, COUNT(*) AS DuplicateCount
FROM Sales
GROUP BY OrderID, ProductID
HAVING COUNT(*) > 1;

-- Ensure that all dates in the Order Date and Shipping Date fields are in the correct format (YYYY-MM-DD).
SELECT OrderID, OrderDate
FROM Orders
WHERE TRY_CONVERT(DATE, OrderDate, 120) IS NULL;

SELECT OrderID, ShippingDate
FROM Orders
WHERE TRY_CONVERT(DATE, ShippingDate, 120) IS NULL;

-- Check for any negative order quantities, which should not exist.
SELECT *
FROM Sales
WHERE OrderQuantity < 0;

-- Generate a summary report to confirm data cleaning.
SELECT 
    COUNT(*) AS TotalSales,
    SUM(Sales) AS TotalSalesValue,
    SUM(Profit) AS TotalProfitValue,
    AVG(OrderQuantity) AS AverageOrderQuantity
FROM Sales;


-- Review the first 10 rows of cleaned data to ensure changes were applied correctly.
SELECT TOP 10 *
FROM Sales;

-- Creating a final table called Sales Sample Sales Data to consolidate the cleaned data.
CREATE TABLE [Sales Sample Sales Data] AS
SELECT 
    O.OrderID,
    O.OrderDate,
    O.ShipDate,
    O.OrderPriority, 
    S.RowID,          
    S.Sales,
    S.Discount,
    S.Profit,
    S.UnitPrice,
    S.ShippingCost,
    S.ShipMode,
    S.OrderQuantity,  -- Ensure this field is included
    P.ProductName,
    P.ProductCategory,
    P.ProductSub-Category,
    P.ProductContainer,
    P.ProductBaseMargin,
    C.Name AS CustomerName,
    C.Segment AS CustomerSegment,
    C.Province,
    C.Region
FROM Sales S
JOIN Orders O ON S.OrderID = O.OrderID  -- OrderID linking field
JOIN Products P ON S.ProductID = P.ProductID  -- ProductID linking field
JOIN Customers C ON O.CustomerID = C.CustomerID; -- CustomerID linking field