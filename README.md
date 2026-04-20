# Big Data Lab v2

Production-style Docker lab for:
- Hadoop HDFS + YARN
- Hive Metastore + HiveServer2
- Spark + PySpark
- Jupyter Lab
- Trino
- Power BI integration

## Stack summary

- 1 NameNode
- 3 DataNodes
- 1 ResourceManager
- 3 NodeManagers
- 1 HistoryServer
- PostgreSQL-backed Hive Metastore
- Hive Metastore + HiveServer2
- Spark Master + 2 Workers
- Jupyter PySpark Notebook
- Trino as BI-friendly SQL gateway

## Quick start

### 1) Prepare
```bash
cp .env .env.local 2>/dev/null || true
```

### 2) Start services
```bash
docker compose up -d
```

### 3) Initialize HDFS
```bash
docker exec -it namenode bash /scripts/init-hdfs.sh
```

### 4) Initialize Hive metastore schema
```bash
docker exec -it hive-metastore bash /opt/hive/bin/schematool -dbType postgres -initSchema
```

If schema already exists, that message is okay.

### 5) Create Hive tables
```bash
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -f /opt/hive/scripts/create-hive-tables.sql
```

### 6) Run PySpark ETL
```bash
docker exec -it jupyter python /home/jovyan/work/sales_etl_pyspark.py
```

## Service URLs

- NameNode UI: http://localhost:9870
- ResourceManager UI: http://localhost:8088
- HistoryServer UI: http://localhost:8188
- Spark Master UI: http://localhost:8080
- Jupyter Lab: http://localhost:8888
- Trino: http://localhost:8085

Jupyter token:
```text
admin123
```

## Sample validation

### Hive
```bash
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive
```

```sql
USE lakehouse;
SHOW TABLES;
SELECT * FROM sales_raw LIMIT 10;
SELECT region, SUM(sales_amount) AS total_sales
FROM sales_gold
GROUP BY region
ORDER BY total_sales DESC;
```

### Trino
```bash
docker exec -it trino trino
```

```sql
SHOW CATALOGS;
SHOW SCHEMAS FROM hive;
SHOW TABLES FROM hive.lakehouse;
SELECT * FROM hive.lakehouse.sales_gold LIMIT 10;
SELECT region, SUM(sales_amount) total_sales
FROM hive.lakehouse.sales_gold
GROUP BY region
ORDER BY total_sales DESC;
```

## Power BI connection options

### Option A: Trino via ODBC
Recommended for this lab.

- Host: your Docker host IP or localhost
- Port: 8085
- Catalog: hive
- Schema: lakehouse

### Option B: HiveServer2 via ODBC
Works, but interactive BI can feel slower.

- Host: your Docker host IP or localhost
- Port: 10000
- Database: lakehouse

### Option C: PostgreSQL export mart
Best when you want a cleaner Power BI refresh path.

Uncomment the JDBC export block in `notebooks/sales_etl_pyspark.py` and point Power BI to PostgreSQL.

## Notes

- This pack is designed for Ubuntu + Docker Compose.
- Default passwords and tokens are for lab/demo use only.
- If an image tag is unavailable on your host architecture, swap the tag to a compatible equivalent and keep the same config files.
