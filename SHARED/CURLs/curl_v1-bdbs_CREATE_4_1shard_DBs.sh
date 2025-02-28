#!/bin/bash

source /root/redis-env-vars.sh

for i in 1 2 3 4; do
  DB_NAME="Test$i"
  DB_PORT="1000$i"
  MEMORY_SIZE=1073741824  # Size in bytes (e.g., 1GB)

  DB_PARAMS='{ "name": "'"${DB_NAME}"'",
    "port": '${DB_PORT}',
    "memory_size": '"${MEMORY_SIZE}"',
    "data_persistence": "aof",
    "aof_policy": "appendfsync-every-sec",
    "shard_key_regex": [
      {
        "regex": ".*\\{(?<tag>.*)\\}.*"
      },
      {
        "regex": "(?<tag>.*)"
      }
    ],
    "shards_count": 1
  }'

  CURL="curl -o $0-$i.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/bdbs"

  echo " . . Executing: $CURL"
  bash -c "$CURL"
  cat $0-$i.json | jq
done