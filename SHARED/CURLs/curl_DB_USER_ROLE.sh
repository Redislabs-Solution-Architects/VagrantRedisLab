#!/bin/bash

# Set environment variables from file (if present) or use default values
test "$redis_env_vars" = '' && echo "Sourcing default /root/redis-env-vars.sh" || echo "Sourcing configured: $redis_env_vars"
test "$redis_env_vars" = '' && source /root/redis-env-vars.sh || source $redis_env_vars

# Loop through all databases in the cluster
for db in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs | jq '.[].uid'); do
  # Print header for current database
    echo " --- Database $db ---"

  # Get ACL and role UIDs for the current database
    redis_acl_uid=()
    role_uid=()
    for uidl in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db | jq '.roles_permissions[].redis_acl_uid'); do
        redis_acl_uid+=("$uidl")
    done #for uidl 1
    for uidl in $(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/bdbs/$db | jq '.roles_permissions[].role_uid'); do
        role_uid+=("$uidl")
    done #for uidl 2

  # Loop through ACLs and roles for the current database
    roles_permissions_count=${#redis_acl_uid[@]}
    for i in $(seq 0 $((roles_permissions_count - 1))); do
    # Print header for current ACL/role combination
        echo " ### Num#: $i ###"

    # Get role information
        role=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/roles/${role_uid[$i]}|jq)
        echo "Role: $role"

    # Get ACL information
        acl=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/redis_acls/${redis_acl_uid[$i]}|jq)
        echo "ACL: $acl"

    # Get user information associated with the current role
        user=$(curl -s -k -u $REDIS_cluster_admin:$REDIS_cluster_password -X GET -H 'Accept: application/json' https://$REDIS_cluster_fqdn:9443/v1/users | jq ".[] | select(.role_uids == [${role_uid[$i]}])")
        echo "USER: $user"
    done #for i

done #for db
