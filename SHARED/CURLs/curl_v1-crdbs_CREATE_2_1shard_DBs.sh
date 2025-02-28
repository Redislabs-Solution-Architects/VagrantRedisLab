#!/bin/bash

source /root/redis-env-vars.sh

for i in 1 2; do
  DB_NAME="Test$i"
  DB_PORT="1000$i"
  MEMORY_SIZE=1073741824  # Size in bytes (e.g., 1GB)

DB_PARAMS='{
    "default_db_config": {
        "name": "'$DB_NAME'",
        "port": '$DB_PORT',
        "memory_size": 1073741824,
        "replication": true,
        "data_persistence": "aof",
        "aof_policy": "appendfsync-every-sec",
        "shards_count": 1,
        "sharding": true,
        "shard_key_regex": [
          {
          "regex": ".*\\{(?<tag>.*)\\}.*"
          },
          {
          "regex": "(?<tag>.*)"
          }
        ]
    },
    "encryption": true,
    "instances": [
        {
            "cluster": {
                "url": "https://'$REDIS_cluster_fqdn':9443",
                "credentials": {
                    "username": "'$REDIS_cluster_admin'",
                    "password": "'$REDIS_cluster_password'"
                },
                "name": "'$REDIS_cluster_fqdn'"
            },
            "compression": 6
        },
        {
            "cluster": {
                "url": "https://rc2.example.com:9443",
                "credentials": {
                    "username": "'$REDIS_cluster_admin'",
                    "password": "'$REDIS_cluster_password'"
                },
                "name": "rc2.example.com"
            },
            "compression": 6
        }
    ],
    "name": "'$DB_NAME'"
}'

CURL="curl -o $0-$i.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/crdbs"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0-$i.json | jq

done