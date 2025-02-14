source /root/redis-env-vars.sh

for db in $(rladmin status databases|grep ^db|awk '{print $1}'|awk -F ':' '{print $2}'); do
echo " . . DB id: $db---------------------------------------------------"
echo "For GA DB availability (at least one endpoint is available). 200 = available/500 = not available"
CURL="curl -o response.json -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/actions/optimize_shards_placement | jq"
echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo
echo "----------------------------------------------------------------"
done # db loop
