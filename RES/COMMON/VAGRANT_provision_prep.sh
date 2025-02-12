REDIS_cluster_fqdn=$4
REDIS_cluster_admin=$5
REDIS_cluster_password=$6
REDIS_first_node_ip=$7
REDIS_SHARED_mount_point=$3
REDIS_self_hostname=$1
VAGRANT_SHARED_mount_point=$2



cat >${VAGRANT_SHARED_mount_point}/_PROVISION/${REDIS_self_hostname}.sh<<EOF
#$(date)
${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_provision_prep.sh $REDIS_cluster_fqdn $REDIS_cluster_admin $REDIS_cluster_password $REDIS_first_node_ip
rm -rf /root/_PROVISION
mkdir -p /root/_PROVISION
ln -s ${REDIS_SHARED_mount_point}/_PROVISION/${REDIS_self_hostname}.sh /root/_PROVISION/${REDIS_self_hostname}.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_install_bins.sh /root/_PROVISION/REDIS_install_bins.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_create_cluster.sh /root/_PROVISION/REDIS_create_cluster.sh
ln -s ${REDIS_SHARED_mount_point}/SCRIPTS/REDIS_uninstall_bins.sh /root/_PROVISION/REDIS_uninstall_bins.sh
EOF
exit 0

setup_redis_env_vars=3 SHARED_mount_point+' '+4 redis_cluster_fqdn+' '+5 redis_cluster_admin+' '+6 redis_cluster_password+' '+ 7first_node_ip

NODES.each do |node|
  system ('sh ./setup.sh '+node[:hostname]+' ../../SHARED '+setup_redis_env_vars)
end

args: [redis_cluster_fqdn, redis_cluster_admin, redis_cluster_password, first_node_ip]


      server.vm.provision "redis-env-vars", type: "shell", path: "../../SHARED/SCRIPTS/REDIS_provision_prep.sh", args: [redis_cluster_fqdn, redis_cluster_admin, redis_cluster_password, first_node_ip]
      server.vm.provision "redis-bins", type: "shell", run: "never", path: "../../SHARED/SCRIPTS/REDIS_install_bins.sh"
      server.vm.provision "redis-cluster", type: "shell", run: "never", path: "../../SHARED/SCRIPTS/REDIS_create_cluster.sh", args: [first_node_ip, redis_cluster_fqdn, redis_cluster_admin, redis_cluster_password, node[:ip]]
      server.vm.provision "remove_redis", type: "shell", run: "never", path: "../../SHARED/SCRIPTS/REDIS_uninstall_bins.sh"