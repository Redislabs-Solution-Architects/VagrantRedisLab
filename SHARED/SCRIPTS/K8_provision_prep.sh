echo "Executing: $0 $@"
K8_subnet=$(echo $1|sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\)\.[0-9]\+/\1/')
echo " . . Creating: /root/k8-env-vars.sh"
cat >/root/k8-env-vars.sh<<EOF
export K8_first_node_ip=$1
export K8_subnet=$K8_subnet
export K8_self_IP=$(hostname -I|sed "s/.*\($K8_subnet\.[0-9]\+\)/\1/")
export K8_nameserver=$2
export K8_SHARED_mount_point=$3
export controlPLANE_IP=$4
export k8Token=$5
export podNETWORKcidr=$6
export metalLB_IPRange=$7
export controlPLANE_PORT=$8
export worker_node_count=$9
EOF
