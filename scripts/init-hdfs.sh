#!/bin/bash
set -e

echo "Creating HDFS directories..."
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /data/raw
hdfs dfs -mkdir -p /data/gold
hdfs dfs -chmod -R 777 /user/hive/warehouse
hdfs dfs -chmod -R 777 /data

if hdfs dfs -test -e /data/raw/sales.csv; then
  echo "sales.csv already exists in HDFS"
else
  hdfs dfs -put -f /datasets/sales.csv /data/raw/sales.csv
fi

echo "HDFS initialization completed."
