#!/bin/bash

source /root/redis-env-vars.sh

echo " ! ! ! WARNING ! ! ! This script will apply curl_v1-bdbs-actions-optimize_shards_placement-*.json files. Press any key to continue."
read -s -n 1

# For all DBs
for db in $(rladmin status databases|grep ^db|awk '{print $1}'|awk -F ':' '{print $2}'); do
echo " . DB id: $db. Loading shard placement."
CURL="curl -o $0.json -s -d @curl_v1-bdbs-actions-optimize_shards_placement-$db.json -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db"
echo " . . Executing: $CURL"
test -f curl_v1-bdbs-actions-optimize_shards_placement-$db.json && bash -c "$CURL" || echo " . . . File curl_v1-bdbs-actions-optimize_shards_placement-$db.json not found."
cat $0.json | jq
echo "----------------------------------------------------------------"
done # db loop