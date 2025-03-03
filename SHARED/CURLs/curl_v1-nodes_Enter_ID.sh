#!/bin/bash

source /root/redis-env-vars.sh

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq '.[] | {node_uid: .uid}'

read -p "Enter U_ID to display node: " U_ID

./curl_v1-nodes_ID.sh $U_ID
