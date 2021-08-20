#!/bin/sh

export MANAGE_LOCAL_HBASE=${MANAGE_LOCAL_HBASE:-true}
export MANAGE_LOCAL_SOLR=${MANAGE_LOCAL_SOLR:-true}
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export HBASE_CONF_DIR=/opt/atlas/conf/hbase

/opt/atlas/bin/atlas_start.py

tail -f /dev/null
