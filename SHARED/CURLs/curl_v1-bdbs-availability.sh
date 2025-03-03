source /root/redis-env-vars.sh

for db in $(rladmin status databases | grep ^db | awk '{print $1}' | awk -F ':' '{print $2}'); do
    echo " . . DB id: $db---------------------------------------------------"
    echo "For GA DB availability (at least one endpoint is available). 200 = available/500 = not available"
    CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/availability"
    echo " . . Executing: $CURL"
    echo
    bash -c "$CURL"
    echo
    for node in $(rladmin status nodes | grep node | awk '{print $3}'); do
        echo
        echo " . . . Each node tested if endpoint is available. 200 = available/500 = not available"
        echo " . . . . NODE IP: $node"
        CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$node:9443/v1/local/bdbs/$db/endpoint/availability"
        echo " . . . . Executing: $CURL"
        echo
        bash -c "$CURL"
        echo
    done # node loop
    echo
    echo "----------------------------------------------------------------"
done # db loop
