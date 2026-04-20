from pyspark.sql import SparkSession
from pyspark.sql.functions import col, month, to_date, year

spark = (
    SparkSession.builder
    .appName("Sales ETL Production v2")
    .master("spark://spark-master:7077")
    .config("spark.sql.warehouse.dir", "/tmp/spark-warehouse")
    .config("hive.metastore.uris", "thrift://hive-metastore:9083")
    .enableHiveSupport()
    .getOrCreate()
)

raw_df = (
    spark.read
    .option("header", True)
    .option("inferSchema", True)
    .csv("/home/jovyan/datasets/sales.csv")
)

gold_df = (
    raw_df
    .withColumn("order_date", to_date(col("order_date"), "yyyy-MM-dd"))
    .withColumn("year", year(col("order_date")))
    .withColumn("month", month(col("order_date")))
    .select(
        "order_id",
        "order_date",
        "year",
        "month",
        "region",
        "product",
        "category",
        col("quantity").cast("int"),
        col("unit_price").cast("double"),
        col("sales_amount").cast("double")
    )
)

spark.sql("CREATE DATABASE IF NOT EXISTS lakehouse")

gold_df.write.mode("overwrite").format("parquet").saveAsTable("lakehouse.sales_gold")

print("Rows loaded:", gold_df.count())
spark.sql(
    """
    SELECT region, SUM(sales_amount) total_sales
    FROM lakehouse.sales_gold
    GROUP BY region
    ORDER BY total_sales DESC
    """
).show()

# Optional export for Power BI through PostgreSQL
# Uncomment if your runtime includes the PostgreSQL JDBC driver.
#
# gold_df.write \
#     .format("jdbc") \
#     .option("url", "jdbc:postgresql://postgres:5432/metastore") \
#     .option("dbtable", "public.sales_gold_export") \
#     .option("user", "hive") \
#     .option("password", "hive123") \
#     .option("driver", "org.postgresql.Driver") \
#     .mode("overwrite") \
#     .save()

spark.stop()
