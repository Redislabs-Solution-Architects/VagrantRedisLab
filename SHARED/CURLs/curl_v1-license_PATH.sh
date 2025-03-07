#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <PATH to luc file>"
test "$1" = '' && exit 1

source /root/redis-env-vars.sh

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"license\":\"$(sed -z 's/\n/\\n/g' $1)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/license"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo