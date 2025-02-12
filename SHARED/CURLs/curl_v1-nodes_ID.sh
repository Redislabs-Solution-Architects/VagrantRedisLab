source /root/redis-env-vars.sh
echo "Executing: curl -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Content-Type: application/json' https://$REDIS_cluster_fqdn:9443/v1/nodes/$1 | jq"
curl -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H "Content-Type: application/json" https://$REDIS_cluster_fqdn:9443/v1/nodes/$1 | jq