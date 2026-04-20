CREATE DATABASE IF NOT EXISTS lakehouse;
USE lakehouse;

CREATE EXTERNAL TABLE IF NOT EXISTS sales_raw (
    order_id STRING,
    order_date STRING,
    region STRING,
    product STRING,
    category STRING,
    quantity INT,
    unit_price DOUBLE,
    sales_amount DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/data/raw/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE TABLE IF NOT EXISTS sales_gold (
    order_id STRING,
    order_date DATE,
    year INT,
    month INT,
    region STRING,
    product STRING,
    category STRING,
    quantity INT,
    unit_price DOUBLE,
    sales_amount DOUBLE
)
STORED AS PARQUET;
