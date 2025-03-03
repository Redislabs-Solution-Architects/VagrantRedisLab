#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <ID>"
test "$1" = '' && exit 1

source /root/redis-env-vars.sh

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes/$1"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq
