#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <PATH to luc file>"
test "$1" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"license\":\"$(sed -z 's/\n/\\n/g' $1)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/license"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo