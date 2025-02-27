#!/bin/bash

source /root/redis-env-vars.sh

# For all DBs
for db in $(rladmin status databases|grep ^db|awk '{print $1}'|awk -F ':' '{print $2}'); do
echo " . DB id: $db. Optimal shard placement."
CURL="curl -s -o curl_v1-bdbs-actions-optimize_shards_placement-$db.json -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/actions/optimize_shards_placement"
echo " . . Executing: $CURL"
bash -c "$CURL"
# We need shards_blueprint parameter wrapper.
sed -i '1s/^/{ "shards_blueprint":\n/' curl_v1-bdbs-actions-optimize_shards_placement-$db.json
echo '}' >> curl_v1-bdbs-actions-optimize_shards_placement-$db.json
echo " . . . curl_v1-bdbs-actions-optimize_shards_placement-$db.json:"
cat curl_v1-bdbs-actions-optimize_shards_placement-$db.json | jq
echo "----------------------------------------------------------------"
done # db loop