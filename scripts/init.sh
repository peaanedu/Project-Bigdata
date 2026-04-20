#!/bin/bash
set -e

echo "[1/4] Waiting briefly for services..."
sleep 15

echo "[2/4] Initialize HDFS folders and upload dataset..."
docker exec -it namenode bash /scripts/init-hdfs.sh

echo "[3/4] Initialize Hive metastore schema..."
docker exec -it hive-metastore bash -lc "/opt/hive/bin/schematool -dbType postgres -initSchema || true"

echo "[4/4] Create Hive tables..."
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /opt/hive/scripts/create-hive-tables.sql

echo "Initialization done."
