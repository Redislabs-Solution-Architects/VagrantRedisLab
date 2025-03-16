#!/bin/bash

test "$1" = '' && echo "Execution is: ./$0 <GUID>"
test "$1" = '' && exit 1

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

CURL="curl -o $0.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X DELETE https://$REDIS_cluster_fqdn:9443/v1/crdbs/$1"

echo " . . Executing: $CURL"
bash -c "$CURL"
cat $0.json | jq

task_id=$(cat $0.json | jq -r '.id')

CURL="curl -o $0-task.json -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -H 'Accept: application/json' -X GET https://$REDIS_cluster_fqdn:9443/v1/crdb_tasks/$task_id"

msg=""
until [ "$msg" == "finished" ]; do
    echo " . . Waiting to complete CRDB task: $task_id"
    bash -c "$CURL"
    cat $0-task.json
    msg=$(cat $0-task.json | jq -r '.status')
    sleep 3
done
