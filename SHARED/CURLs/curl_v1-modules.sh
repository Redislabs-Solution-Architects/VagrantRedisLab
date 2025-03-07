#!/bin/bash

source /root/redis-env-vars.sh

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/modules"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

cat $0.json | jq '.[] | {module_name: .module_name, semantic_version: .semantic_version, min_redis_version: .min_redis_version}'