#!/bin/bash
/etc/init.d/ssh start

# Prepare Postgres for Hive Metastore
su postgres -c '/usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main2 start'
sleep 2
psql -U postgres -c "CREATE USER hiveuser WITH PASSWORD 'hiveuser';"
psql -U postgres -c "CREATE DATABASE metastore;"
/root/apache-hive-2.3.6-bin/bin/schematool -dbType postgres -initSchema

# Start HDFS
/root/hadoop-2.9.2/sbin/start-all.sh


# Start Presto
export PRESTO_HOME=/root/presto-server-318

use_query_max_memory=${QUERY_MAX_MEMORY:-"2GB"}
use_query_max_memory_per_node=${QUERY_MAX_MEMORY_PER_NODE:-"1GB"}
use_query_max_total_memory_per_node=${QUERY_MAX_TOTAL_MEMORY_PER_NODE:-"1GB"}
use_jvm_heap=${JAVA_HEAP_SIZE:-"3G"}

sed "s/{QUERY_MAX_MEMORY}/$use_query_max_memory/" $PRESTO_HOME/etc/config.properties.template | \
    sed "s/{QUERY_MAX_MEMORY_PER_NODE}/$use_query_max_memory_per_node/" | \
    sed "s/{QUERY_MAX_TOTAL_MEMORY_PER_NODE}/$use_query_max_total_memory_per_node/" \
    > $PRESTO_HOME/etc/config.properties

sed "s/{JAVA_HEAP_SIZE}/$use_jvm_heap/" $PRESTO_HOME/etc/jvm.config.template \
    > $PRESTO_HOME/etc/jvm.config

sed "s/{AWS_ACCESS_KEY}/$AWS_ACCESS_KEY_ID/" $PRESTO_HOME/etc/catalog/hive.properties.template | \
    sed "s/{AWS_SECRET_ACCESS_KEY}/$AWS_SECRET_ACCESS_KEY/" \
    > $PRESTO_HOME/etc/catalog/hive.properties

$PRESTO_HOME/bin/launcher.py start


# Start Metastore (this keeps running in the foregound)
/root/apache-hive-2.3.6-bin/bin/hive --service metastore