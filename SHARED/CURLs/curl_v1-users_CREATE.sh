#!/bin/bash

test "$1" = '' && echo "Execution is: $0 <user_name> <user_password> <email> <role_id>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: $0 <user_name> <user_password> <email> <role_id>"
test "$2" = '' && exit 1
test "$3" = '' && echo "Execution is: $0 <user_name> <user_password> <email> <role_id>"
test "$3" = '' && exit 1
test "$4" = '' && echo "Execution is: $0 <user_name> <user_password> <email> <role_id>"
test "$4" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars


USER_PARAMS='{
  "name": "'$1'",
  "email": "'$3'",
  "password": "'$2'",
  "role_uids": ['$4']
}'


CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '$USER_PARAMS' https://$REDIS_cluster_fqdn:9443/v1/users"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq