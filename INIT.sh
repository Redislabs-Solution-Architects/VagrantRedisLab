############### DO NOT CHANGE ###############

test "$1" = '' && echo "Execution is: ./INIT.sh ENVIRONMENTfile";
test "$1" = '' && exit 1;

source $1

echo "node_names:${node_names[@]}"
echo "node_ips: ${node_ips[@]}"

mkdir -p ./SHARED/_PROVISION
cat <<EOF | tee ./SHARED/_PROVISION/README.txt
This is the temporary folder for all environment stuff. Do not modify anything here.
EOF

# Re-assign count based on the current array config.
node_count=${#node_ips[@]}

setup_redis_env_vars="$SHARED_mount_point $redis_cluster_fqdn $redis_cluster_admin $redis_cluster_password ${node_ips[0]} $nameserver $ENV_name"

for i in $(seq 0 $((node_count-1)) ); do
    #echo "echo Executing - : \$0" > ./RES/${ENV_name}/${node_names[i]}.${redis_cluster_fqdn}.sh
    #echo "../COMMON/LOCAL_provision_prep.sh ${node_names[i]} ../../SHARED $setup_redis_env_vars" >> ./RES/${ENV_name}/${node_names[i]}.${redis_cluster_fqdn}.sh
    ./RES/COMMON/LOCAL_provision_prep.sh ${node_names[i]} ./SHARED $setup_redis_env_vars
done

######################################################### Below is the Vagrant related part.
# Vagrant NODES conig.
# 1st element
vagrant_NODES=([1]="NODES = [")
# array indexing starts from 0. For all records in array.
for i in $(seq 0 $((node_count-1)) ); do
    vagrant_NODES+=([i+2]="{ :hostname => '"${node_names[i]}"', :ip => '"${node_ips[i]}"' },")
#    echo ${node_names[i]}
#    echo $i
done
vagrant_NODES+=([$((node_count+2))]="]")
# Remove environmet folder.
rm -rf ./RES/$ENV_name
# Create environmet folder.
mkdir -p ./RES/$ENV_name

# Instantiate Vagrantfile.
cat /dev/null > ./RES/$ENV_name/Vagrantfile
# Fill Vagrantfile with nodes.
for z in $(seq 1 $((node_count+2))); do
echo ${vagrant_NODES[z]} >> ./RES/$ENV_name/Vagrantfile
done
# Add Vagrant configuration.
cat >> ./RES/$ENV_name/Vagrantfile<<EOF
ENV_name="$ENV_name"
SHARED_mount_point="$SHARED_mount_point"
redis_cluster_fqdn="$redis_cluster_fqdn"
network_type="$network_type"
ram_size="$ram_size"
cpu_count="$cpu_count"
Vagrant.configure("2") do |config|
  NODES.each do |node|
    #system ('sh ./'+node[:hostname]+'.'+redis_cluster_fqdn+'.sh')
    config.vm.define node[:hostname] do |server|
      server.vm.hostname = node[:hostname]
      server.vm.provider :virtualbox do |vb|
        vb.name    = node[:hostname]
        vb.memory = ram_size
        vb.cpus = cpu_count
      end
      server.vm.box = "generic/centos8s"
      server.vm.hostname = node[:hostname]
      server.vm.network network_type, ip: node[:ip]
      server.vm.synced_folder "../../SHARED", SHARED_mount_point
      server.vm.provision "redis-provision-prep", type: "shell", run: "never", path: "../COMMON/REDIS_provision_prep.sh", args: [SHARED_mount_point, node[:hostname], ENV_name]
      server.vm.provision "redis-init", type: "shell", run: "never", path: "../COMMON/REDIS_nodes_init.sh"
      server.vm.provision "redis-install-bins", type: "shell", run: "never", path: "../COMMON/REDIS_install_bins.sh"
      server.vm.provision "redis-create-cluster", type: "shell", run: "never", path: "../COMMON/REDIS_create_cluster.sh"
      server.vm.provision "redis-uninstall-bins", type: "shell", run: "never", path: "../COMMON/REDIS_uninstall_bins.sh"
      server.vm.provision "redis-yum-packages", type: "shell", run: "never", path: "../COMMON/setup_yum.sh"
    end
  end
end
EOF

cat >> ./RES/$ENV_name/redis-init.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with redis-provision-prep
vagrant provision --provision-with redis-init
EOF

cat >> ./RES/$ENV_name/redis-rescratch-bins+cluster.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with redis-uninstall-bins
vagrant provision --provision-with redis-provision-prep
vagrant provision --provision-with redis-install-bins
vagrant provision --provision-with redis-create-cluster 
EOF

cat >> ./RES/$ENV_name/redis-install-bins+cluster.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with redis-provision-prep
vagrant provision --provision-with redis-init
vagrant provision --provision-with redis-install-bins
vagrant provision --provision-with redis-create-cluster 
EOF

cat >> ./RES/$ENV_name/redis-uninstall.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with redis-uninstall-bins
EOF

chmod +x ./RES/$ENV_name/*.sh