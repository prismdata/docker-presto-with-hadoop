This image offers Presto with other necessary components in a single image. This image is only
useful for quick tests since the metadata (e.g., schemas, tables) will be gone when the container is
removed.


# Features

1. Unlike most other Docker images for the Presto database, this image offers multiple necessary 
components (e.g., Hadoop, Hive, PostgreSQL) in a single image. Thus, much easier to install without
setting network bridges to other containers.
2. The classpath for Amazon S3 connections are properly set. As a result, large data files can 
easily be stored in the cloud.


# How to run

For connection to regular Hive:

```bash
docker run -d --name presto-with-hadoop yongjoopark/presto-with-hadoop
```

For additional connection to S3:

```bash
docker run -d --name presto-with-hadoop \
-e AWS_ACCESS_KEY_ID={YourAccessKey} \
-e AWS_SECRET_ACCESS_KEY={YourSecretAccessKey} \
yongjoopark/presto-with-hadoop
```


# More memory for Presto?

Provide the following environment variables. The startup script picks those variables and set
configuration files accordingly.

```bash
docker run -d --name presto-with-hadoop \
-e AWS_ACCESS_KEY_ID={YourAccessKey} \
-e AWS_SECRET_ACCESS_KEY={YourSecretAccessKey} \
-e QUERY_MAX_MEMORY='50GB' \
-e QUERY_MAX_MEMORY_PER_NODE='40GB' \
-e QUERY_MAX_TOTAL_MEMORY_PER_NODE='40GB' \
-e JAVA_HEAP_SIZE='60G'
yongjoopark/presto-with-hadoop
```


# Command-line interface for Presto

After starting a container as described above, you can use Presto's command-line interface as
follows:

```bash
docker exec -it presto-with-hadoop presto-cli
```



# Versions

All components are located in `/root/`.

- Hadoop: hadoop-2.9.2
- PostgreSQL (for Hive Metastore): 10
- Hive: 2.3.6
- Presto: 318
- Ubuntu: 18.04

Note that Presto is only compatible with Hadoop2 (not Hadoop3).