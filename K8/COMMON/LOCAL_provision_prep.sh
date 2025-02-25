echo "Executing step: COMMON/LOCAL_provision_prep.sh"
echo " . Executing: $0 $@"
K8_self_hostname=$1
VAGRANT_SHARED_mount_point=$2
K8_SHARED_mount_point=$3
K8_first_node_ip=$4
K8_nameserver=$5
ENV_name=$6
controlPLANE_IP=$7
k8Token=$8
podNETWORKcidr=$9
metalLB_IPRange=${10}
controlPLANE_PORT=${11}
worker_node_count=${12}

echo " . . Executing: mkdir -p ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name"
mkdir -p ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name

echo " . . Creating ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/INIT_host.sh"
echo "cd \$(dirname \$0)&&./\$(hostname -s).sh" > ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/INIT_host.sh

cat >${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/DOitALL.sh<<EOF
echo "Executing: \$0 \$@"
cd \$(dirname \$0) && \
./INIT_host.sh && \
sleep 2 && \
/root/_PROVISION/K8_nodes_init.sh && \
sleep 2 && \
/root/_PROVISION/K8_install_bins.sh&&ls -lrt && \
sleep 2 && \
/root/_PROVISION/K8_create_cluster-cp.sh && \
sleep 2 && \
/root/_PROVISION/K8_create_cluster-w.sh
EOF

echo " . . Creating: ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/${K8_self_hostname}.sh"
cat >${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/${K8_self_hostname}.sh<<EOF
#$(date)
echo "Executing: \$0 \$@"
#                                                     1                 2              3                      4                5        6               7                8                  9
${K8_SHARED_mount_point}/SCRIPTS/K8_provision_prep.sh $K8_first_node_ip $K8_nameserver $K8_SHARED_mount_point $controlPLANE_IP $k8Token $podNETWORKcidr $metalLB_IPRange $controlPLANE_PORT $worker_node_count
rm -rf /root/_PROVISION
mkdir -p /root/_PROVISION
ln -s ${K8_SHARED_mount_point}/_PROVISION/$ENV_name/${K8_self_hostname}.sh /root/_PROVISION/${K8_self_hostname}.sh
ln -s ${K8_SHARED_mount_point}/SCRIPTS/K8_nodes_init.sh /root/_PROVISION/K8_nodes_init.sh
ln -s ${K8_SHARED_mount_point}/SCRIPTS/K8_install_bins.sh /root/_PROVISION/K8_install_bins.sh
ln -s ${K8_SHARED_mount_point}/SCRIPTS/K8_create_cluster-cp.sh /root/_PROVISION/K8_create_cluster-cp.sh
ln -s ${K8_SHARED_mount_point}/SCRIPTS/K8_create_cluster-w.sh /root/_PROVISION/K8_create_cluster-w.sh
EOF