#!/bin/bash

test "$1" = '' && echo "Execution is: $0 <ID> <bucket_name> <access_key_id> <secret_access_key>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: $0 <ID> <bucket_name> <access_key_id> <secret_access_key>"
test "$2" = '' && exit 1
test "$3" = '' && echo "Execution is: $0 <ID> <bucket_name> <access_key_id> <secret_access_key>"
test "$3" = '' && exit 1
test "$4" = '' && echo "Execution is: $0 <ID> <bucket_name> <access_key_id> <secret_access_key>"
test "$4" = '' && exit 1


test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Content-type: application/json' -d '{ \"export_location\": {\"type\": \"s3\", \"bucket_name\": \"$2\", \"subdir\": \"backup\", \"access_key_id\": \"$3\", \"secret_access_key\": \"$4\"}, \"email_notification\": false }' -X POST https://$REDIS_cluster_fqdn:9443/v1/bdbs/$1/actions/export"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo