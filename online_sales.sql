CREATE DATABASE IF NOT EXISTS online_sales;
USE online_sales;

DROP TABLE IF EXISTS sales;

-- data imported from table import wizard

SET GLOBAL local_infile = 1;

select count(*) from sales;

describe sales;

CREATE TABLE IF NOT EXISTS cleaned_sales AS
SELECT
    InvoiceNo AS OrderId,
    StockCode,
    Description,
    Quantity,
    InoiceDate AS OrderDate,
    UnitPrice,
    CustomerID,
    Country,
    (Quantity * UnitPrice) AS revenue
FROM sales
WHERE
    Quantity > 0 AND
    UnitPrice > 0 AND
    InvoiceNo NOT LIKE 'C%';

SELECT
    YEAR(OrderDate) AS year,
    MONTH(OrderDate) AS month,
    COUNT(DISTINCT OrderId) AS order_volume,
    SUM(revenue) AS total_revenue
FROM cleaned_sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY year, month;

SELECT
    order_year,
    order_month,
    total_orders,
    unique_orders,
    total_revenue
FROM revenue_summary
ORDER BY total_revenue DESC
LIMIT 10;

CREATE TABLE IF NOT EXISTS revenue_summary AS
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(revenue) AS total_revenue
FROM cleaned_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

SELECT
    MONTH(InvoiceDate) AS month,
    COUNT(DISTINCT InvoiceNo) AS order_volume,
    SUM(Quantity * UnitPrice) AS total_revenue
FROM sales
WHERE YEAR(InvoiceDate) = 2020
GROUP BY MONTH(InvoiceDate)
ORDER BY month;


select distinct(InvoiceDate) from sales;	--- year = 2020

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    SUM(Quantity * UnitPrice) AS total_revenue
FROM sales
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY total_revenue DESC
LIMIT 5;


SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    COUNT(DISTINCT InvoiceNo) AS order_volume
FROM sales
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY order_volume DESC
LIMIT 6;

# Top sales by country:
SELECT
    Country,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(revenue) AS total_revenue
FROM cleaned_sales
GROUP BY Country
ORDER BY total_revenue DESC;

# Top 5 customers by revenue:
SELECT
    CustomerID,
    COUNT(DISTINCT order_id) AS orders,
    SUM(revenue) AS total_revenue
FROM cleaned_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 5;

## Total revenue per product:
SELECT
    StockCode,
    Description,
    SUM(revenue) AS product_revenue
FROM cleaned_sales
GROUP BY StockCode, Description
ORDER BY product_revenue DESC
LIMIT 10;
