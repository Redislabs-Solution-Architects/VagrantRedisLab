#!/bin/bash

test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

# Retrieve list of users' uid from Redis server
usrs=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/users | jq '.[].uid')

# Iterate through each user's uid and retrieve additional information
for usr in $usrs; do
    # Get user name from Redis server using their uid
    usr_name=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/users/${usr} | jq .name)

    # Get user role's uid from Redis server using their uid
    usr_role_uid=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/users/${usr} | jq .role_uids[0])

    # Retrieve list of databases that the user has access to, based on their role
    DBs=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs | jq ".[] | select(.roles_permissions[].role_uid == $usr_role_uid)" | jq -r .name)

    # Print user name and databases they have access to
    echo "User Name: $usr_name, Databases: $(echo $DBs | sed 's/\r/,/g')"
done #for usr
