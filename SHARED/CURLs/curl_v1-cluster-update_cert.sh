#!/bin/bash

source /root/redis-env-vars.sh

cluster_name=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/cluster | jq -r '.name')
echo "cluster_name: $cluster_name"

/opt/redislabs/utils/generate_self_signed_certs.sh -f $cluster_name && ls -lrt /tmp/*.pem

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"name\": \"metrics_exporter_cert\",\"key\":\"$(sed -z 's/\n/\\n/g' /tmp/metrics_key.pem)\",\"certificate\":\"$(sed -z 's/\n/\\n/g' /tmp/metrics_cert.pem)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/cluster/update_cert"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"name\": \"api_cert\",\"key\":\"$(sed -z 's/\n/\\n/g' /tmp/api_key.pem)\",\"certificate\":\"$(sed -z 's/\n/\\n/g' /tmp/api_cert.pem)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/cluster/update_cert"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"name\": \"cm_cert\",\"key\":\"$(sed -z 's/\n/\\n/g' /tmp/cm_key.pem)\",\"certificate\":\"$(sed -z 's/\n/\\n/g' /tmp/cm_cert.pem)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/cluster/update_cert"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"name\": \"proxy_cert\",\"key\":\"$(sed -z 's/\n/\\n/g' /tmp/proxy_key.pem)\",\"certificate\":\"$(sed -z 's/\n/\\n/g' /tmp/proxy_cert.pem)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/cluster/update_cert"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo

CURL="curl -w '%{http_code}' -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X PUT -H 'Content-Type: application/json' \
-d '{\"name\": \"syncer_cert\",\"key\":\"$(sed -z 's/\n/\\n/g' /tmp/syncer_key.pem)\",\"certificate\":\"$(sed -z 's/\n/\\n/g' /tmp/syncer_cert.pem)\"}' \
https://$REDIS_cluster_fqdn:9443/v1/cluster/update_cert"

echo " . . Executing: $CURL"
echo
bash -c "$CURL"
echo
