#!/bin/bash

#source /root/redis-env-vars.sh

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq '.[] | {node_uid: .uid}'

read -p "Enter UID to display node: " U_ID

./curl_v1-nodes_ID.sh $U_ID
