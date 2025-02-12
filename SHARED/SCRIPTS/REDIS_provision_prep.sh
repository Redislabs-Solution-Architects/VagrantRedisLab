REDIS_subnet=$(echo $4|sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.[0-9]\+/\1/')
echo " . . Creating /root/redis-env-vars.sh"
cat >/root/redis-env-vars.sh<<EOF
export REDIS_cluster_fqdn=$1
export REDIS_cluster_admin=$2
export REDIS_cluster_password=$3
export REDIS_first_node_ip=$4
export REDIS_subnet=$REDIS_subnet
export REDIS_self_IP=$(hostname -I|sed "s/.*\($REDIS_subnet\.[0-9]\+\)/\1/")
EOF