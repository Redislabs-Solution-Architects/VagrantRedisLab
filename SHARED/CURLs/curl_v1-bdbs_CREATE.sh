#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: ./$0 <DB-NAME> <DB_PORT>"
test "$2" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

DB_NAME="$1"
DB_PORT="$2"
MEMORY_SIZE=1073741824  # Size in bytes (e.g., 1GB)

DB_PARAMS='{ "name": "'"${DB_NAME}"'",
  "port": '${DB_PORT}',
  "memory_size": '"${MEMORY_SIZE}"',
  "replication": true,
  "data_persistence": "aof",
  "aof_policy": "appendfsync-every-sec",
  "sharding": true,
  "shard_key_regex": [
    {
      "regex": ".*\\{(?<tag>.*)\\}.*"
    },
    {
      "regex": "(?<tag>.*)"
    }
  ],
  "shards_count": 2
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


exit 0


{
    "name": "mydb01",
    "memory_size": 100000000,
    "replication": true,
    "eviction_policy": "volatile-lru",
    "sharding": false,
    "type": "redis",
    "oss_cluster": false,
    "proxy_policy": "single",
    "shards_placement": "dense",
    "port": 12100,
    "uid": 10,
    "authentication_redis_pass": "Zxas12Qw",
    "module_list": [
        {
            "module_args": "PARTITIONS AUTO",
            "module_name": "search",
            "semantic_version": "2.0.8"
        },
        {
            "module_args": "",
            "module_name": "ReJSON",
            "semantic_version": "1.0.7"
        }
    ]
}
curl -X POST -H ‘Content-type: application/json’ -u igor.borsutsky@redislabs.com:Password 
-d ‘{ “name”: “mydb01", “memory_size”: 100000000, “replication”: true, “eviction_policy”: “volatile-lru”, “sharding”: false, “type”: “redis”, “oss_cluster”: false, “proxy_policy”: “single”, “shards_placement”: “dense”, “port”: 12100, “uid”: 10, “authentication_redis_pass”: “Zxas12Qw”, “module_list”: [{“module_args”: “PARTITIONS AUTO”,“module_name”: “search”, “semantic_version”: “2.0.8”},{“module_args”: “”, “module_name”: “ReJSON”, “semantic_version”: “1.0.7”}]}’ -k https://c101.igorbo.cs.redislabs.com:9443/v1/bdbs