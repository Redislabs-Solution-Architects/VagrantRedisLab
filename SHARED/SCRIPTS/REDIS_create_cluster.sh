echo "Executing $0 $@"
sleep 2
source /root/redis-env-vars.sh

test -f /root/rl_uninstall.sh_running && echo 'The test -f /root/rl_uninstall.sh_running is positive. Exit.'
test -f /root/rl_uninstall.sh_running && exit 0
while test -f /root/RES_install.sh_running; do echo "$(date) - Exists /root/RES_install.sh_running. sleep 20."; echo; tail -1 /root/RES_install.sh_log; echo; sleep 20; done

source /etc/opt/redislabs/redislabs_env_config.sh

echo " . . Testing rladmin status"
which rladmin || exit 1
rladmin status;rladmin_result=$?
#echo $rladmin_result
test $rladmin_result -eq 0 && echo " . . Node already in a Redis cluster, exit..."
test $rladmin_result -eq 0 && exit 0 || echo " . . Node not in a Redis cluster, continue..."


hostname -I|grep $REDIS_first_node_ip;hostname_result=$?
#echo $hostname_result
test $hostname_result -eq 0 && echo " . . Running: rladmin cluster create name $REDIS_cluster_fqdn username $REDIS_cluster_admin password $REDIS_cluster_password addr $REDIS_self_IP external_addr $REDIS_self_IP" || \
echo " . . Running: rladmin cluster join nodes $REDIS_first_node_ip username $REDIS_cluster_admin password $REDIS_cluster_password addr $REDIS_self_IP external_addr $REDIS_self_IP"

test $hostname_result -eq 0 && (rladmin cluster create name $REDIS_cluster_fqdn username $REDIS_cluster_admin password $REDIS_cluster_password addr $REDIS_self_IP external_addr $REDIS_self_IP; sleep 5) || \
rladmin cluster join nodes $REDIS_first_node_ip username $REDIS_cluster_admin password $REDIS_cluster_password addr $REDIS_self_IP external_addr $REDIS_self_IP

