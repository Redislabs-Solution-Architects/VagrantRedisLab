echo "Executing step: COMMON/LOCAL_provision_prep.sh"
echo " . Executing: $0 $@"
REDIS_self_hostname=$1
VAGRANT_SHARED_mount_point=$2
REDIS_SHARED_mount_point=$3
REDIS_cluster_fqdn=$4
REDIS_cluster_admin=$5
REDIS_cluster_password=$6
REDIS_first_node_ip=$7
REDIS_nameserver=$8
ENV_name=$9

echo " . . Executing: mkdir -p ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name"
mkdir -p ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name

echo " . . Executing: echo \"./\$(hostname -s).sh\" > ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/INIT_host.sh"
echo "cd \$(dirname \$0)&&./\$(hostname -s).sh" > ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/INIT_host.sh

cat >${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/DOitALL.sh<<EOF
echo "Executing: \$0 \$@"
cd \$(dirname \$0) && \
./INIT_host.sh && \
sleep 2 && \
/root/_PROVISION/REDIS_nodes_init.sh && \
sleep 2 && \
/root/_PROVISION/REDIS_install_bins.sh&&ls -lrt && \
sleep 2 && \
/root/_PROVISION/REDIS_create_cluster.sh
EOF

echo " . . Creating: ${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/${REDIS_self_hostname}.sh"
cat >${VAGRANT_SHARED_mount_point}/_PROVISION/$ENV_name/${REDIS_self_hostname}.sh<<EOF
#$(date)
echo "Executing: \$0 \$@"
${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_provision_prep.sh $REDIS_cluster_fqdn $REDIS_cluster_admin $REDIS_cluster_password $REDIS_first_node_ip $REDIS_nameserver $REDIS_SHARED_mount_point
rm -rf /root/_PROVISION
mkdir -p /root/_PROVISION
ln -s ${REDIS_SHARED_mount_point}/_PROVISION/$ENV_name/${REDIS_self_hostname}.sh /root/_PROVISION/${REDIS_self_hostname}.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_install_bins.sh /root/_PROVISION/REDIS_install_bins.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_create_cluster.sh /root/_PROVISION/REDIS_create_cluster.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_uninstall_bins.sh /root/_PROVISION/REDIS_uninstall_bins.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_nodes_init.sh /root/_PROVISION/REDIS_nodes_init.sh
EOF