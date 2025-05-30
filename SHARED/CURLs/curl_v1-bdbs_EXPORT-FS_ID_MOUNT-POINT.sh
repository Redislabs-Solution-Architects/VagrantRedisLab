#!/bin/bash

test "$1" = '' && echo "Execution is: $0 <ID> <MOUNT-POINT>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: $0 <ID> <MOUNT-POINT>"
test "$2" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Content-type: application/json' -d '{ \"export_location\": {\"type\": \"mount_point\", \"path\": \"$2\"}, \"email_notification\": false }' -X POST https://$REDIS_cluster_fqdn:9443/v1/bdbs/$1/actions/export"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo