source /root/redis-env-vars.sh

for db in $(rladmin status databases|grep ^db|awk '{print $1}'|awk -F ':' '{print $2}'); do
echo " . . DB id: $db. Optimal shard placement."
echo
CURL="curl -o response.json -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db/actions/optimize_shards_placement"
echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo
cat response.json | jq
rm -f response.json
echo "----------------------------------------------------------------"
done # db loop
