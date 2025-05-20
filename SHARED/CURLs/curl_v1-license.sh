#!/bin/bash

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

echo " . . Executing: curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET https://$REDIS_cluster_fqdn:9443/v1/license|jq -r .license"
echo -e "$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET https://$REDIS_cluster_fqdn:9443/v1/license|jq -r .license)"