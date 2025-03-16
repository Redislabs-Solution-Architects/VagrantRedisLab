#!/bin/bash

# Create 2 DBs without and with Search/JSON modules

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

DB_NAME="Test"
DB_PORT="10001"
MEMORY_SIZE=1073741824 # Size in bytes (e.g., 1GB)

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

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/bdbs"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

action_uid=$(cat $0.json | jq -r '.action_uid')

CURL="curl -o $0-action.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Accept: application/json' -X GET https://$REDIS_cluster_fqdn:9443/v1/actions/$action_uid"

msg=""
until [ "$msg" == "completed" ]; do
  echo " . . Waiting to complete action: action_uid"
  bash -c "$CURL"
  cat $0-action.json
  msg=$(cat $0-action.json | jq -r '.status')
  sleep 1
done

# take default redis version from the 1st DB
redis_version=$(cat $0.json | jq '.redis_version')

# get modules version based on redis_version
search_version=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/modules | \
jq "last(.[] |select( .module_name == \"search\" and .min_redis_version == $redis_version) | .semantic_version)")
ReJSON_version=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/modules | \
jq "last(.[] |select( .module_name == \"ReJSON\" and .min_redis_version == $redis_version) | .semantic_version)")

DB_NAME="TestM"
DB_PORT="10002"
MEMORY_SIZE=1073741824 # Size in bytes (e.g., 1GB)

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
    "shards_count": 1,
    "module_list": [
        {
            "module_args": "PARTITIONS AUTO",
            "module_name": "search",
            "semantic_version": '$search_version'
        },
        {
            "module_args": "",
            "module_name": "ReJSON",
            "semantic_version": '$ReJSON_version'
        }
    ]
  }'

CURL="curl -o $0-M.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$DB_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/bdbs"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0-M.json | jq

action_uid=$(cat $0-M.json | jq -r '.action_uid')

CURL="curl -o $0-M-action.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Accept: application/json' -X GET https://$REDIS_cluster_fqdn:9443/v1/actions/$action_uid"

msg=""
until [ "$msg" == "completed" ]; do
  echo " . . Waiting to complete action: action_uid"
  bash -c "$CURL"
  cat $0-M-action.json
  msg=$(cat $0-M-action.json | jq -r '.status')
  sleep 1
done
