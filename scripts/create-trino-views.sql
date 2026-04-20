CREATE SCHEMA IF NOT EXISTS hive.lakehouse;

CREATE OR REPLACE VIEW hive.lakehouse.v_sales_summary AS
SELECT
    region,
    category,
    year,
    month,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_qty
FROM hive.lakehouse.sales_gold
GROUP BY region, category, year, month;
