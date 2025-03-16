#!/bin/bash

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

for db in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs | jq '.[] | .uid'); do
    echo " > > > DB id: $db. General availability."
    echo
    echo "For GA DB availability (at least one endpoint is available). 200 = available/500 = not available"
    CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/availability"
    echo " . . Executing: $CURL"
    echo
    bash -c "$CURL"
    echo; echo
    echo " > > > > DB id: $db. Per node availability (for LB, all_nodes/all_master_nodes)."
    for node in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes | jq '.[] | .addr'); do
        echo
        echo " . . . Each node tested if endpoint is available. 200 = available/500 = not available"
        echo " . . . . NODE IP: $node"
        CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$node:9443/v1/local/bdbs/$db/endpoint/availability"
        echo " . . . . Executing: $CURL"
        echo
        bash -c "$CURL"
        echo
    done # node loop
    echo "----------------------------------------------------------------"
done # db loop
