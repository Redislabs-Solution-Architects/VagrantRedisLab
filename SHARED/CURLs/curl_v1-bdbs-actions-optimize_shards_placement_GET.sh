#!/bin/bash

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

# For all DBs
for db in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs | jq '.[] | .uid'); do
    echo " . DB id: $db. Optimal shard placement."
    CURL="curl -s -o curl_v1-bdbs-actions-optimize_shards_placement-$db.json -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/actions/optimize_shards_placement"
    echo " . . Executing: $CURL"
    bash -c "$CURL"
    # We need shards_blueprint parameter wrapper.
    sed -i '1s/^/{ "shards_blueprint":\n/' curl_v1-bdbs-actions-optimize_shards_placement-$db.json
    echo '}' >>curl_v1-bdbs-actions-optimize_shards_placement-$db.json
    echo " . . . curl_v1-bdbs-actions-optimize_shards_placement-$db.json:"
    cat curl_v1-bdbs-actions-optimize_shards_placement-$db.json | jq
    echo "----------------------------------------------------------------"
done # db loop