# Docker Image - Jupyter Notebook

This image can be used for local development.

The local Spark installation supports:
- AWS S3
- GCP BigQuery
- GCP GS

It doesn't support AWS Glue Data Catalog.

# How to buid this Docker image
```shell
    task build-docker-image
```

# How to run a Docker container with local credentials

Start a Docker container from the Docker image by running:
```shell
    task run-docker-container

    # or

   docker run -it --rm \
   -p 8888:8888 \
   -p 4040:4040 \
   --user root \
   -e GRANT_SUDO=yes \
   -e AWS_PROFILE=$AWS_PROFILE \
   -v "$HOME/.aws":/home/jovyan/.aws \
   -v "$HOME":/home/jovyan/work \
   local.io/mleuthold/jupyter/pyspark-notebook:spark-3.2.0
```

- `-v "$HOME":/home/jovyan/work` mounts HOME folder into Docker container to access all local files
- `-e AWS_PROFILE=$AWS_PROFILE` use locally provided AWS profile in Docker container
- `-v "$HOME/.aws":/home/jovyan/.aws` use locally provided AWS credentials in Docker container

# Miscellaneous

Example code to read data from S3:
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local") \
    .appName("Word Count") \
    .config("spark.some.config.option", "some-value") \
    .getOrCreate()

spark.read.parquet('s3a://BUCKET/PATH/*.snappy.parquet')
```