#!/bin/bash

test "$1" = '' && echo "Execution is: $0 <ID> <NAME>"
test "$1" = '' && exit 1
test "$2" = '' && echo "Execution is: $0 <ID> <NAME>"
test "$2" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Content-type: application/json' -d '{ \"name\": \"$2\"}' -X PUT https://$REDIS_cluster_fqdn:9443/v1/bdbs/$1"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

action_uid=$(cat $0.json | jq -r '.action_uid')

CURL="curl -o $0-action.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Accept: application/json' -X GET https://$REDIS_cluster_fqdn:9443/v1/actions/$action_uid"

msg=""
until [ "$msg" == "completed" ]; do
    echo " . . Waiting to complete action: action_uid"
    bash -c "$CURL"
    cat $0-action.json
    msg=$(cat $0-action.json | jq -r '.status')
    sleep 1
done
