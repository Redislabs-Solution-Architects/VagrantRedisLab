source /root/redis-env-vars.sh
CURL="curl -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes/$1 | jq"
echo " . . Executing: $CURL"
bash -c "$CURL"