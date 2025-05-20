############### DO NOT CHANGE ###############

test "$1" = '' && echo "Execution is: ./K8-INIT.sh ENVIRONMENTfile";
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

setup_k8_env_vars="$SHARED_mount_point ${node_ips[0]} $nameserver $ENV_name $controlPLANE_IP $k8Token $podNETWORKcidr $metalLB_IPRange $controlPLANE_PORT $((node_count-1))"

for i in $(seq 0 $((node_count-1)) ); do
    #echo "echo Executing - : \$0" > ./K8/${ENV_name}/${node_names[i]}.${k8_cluster_fqdn}.sh
    #echo "../COMMON/LOCAL_provision_prep.sh ${node_names[i]} ../../SHARED $setup_k8_env_vars" >> ./K8/${ENV_name}/${node_names[i]}.${k8_cluster_fqdn}.sh
    ./K8/COMMON/LOCAL_provision_prep.sh ${node_names[i]} ./SHARED $setup_k8_env_vars
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
rm -rf ./K8/$ENV_name/*
# Create environmet folder.
mkdir -p ./K8/$ENV_name

# Instantiate Vagrantfile.
cat /dev/null > ./K8/$ENV_name/Vagrantfile
# Fill Vagrantfile with nodes.
for z in $(seq 1 $((node_count+2))); do
echo ${vagrant_NODES[z]} >> ./K8/$ENV_name/Vagrantfile
done
# Add Vagrant configuration.
cat >> ./K8/$ENV_name/Vagrantfile<<EOF
ENV_name="$ENV_name"
SHARED_mount_point="$SHARED_mount_point"
network_type="$network_type"
ram_size="$ram_size"
cpu_count="$cpu_count"
Vagrant.configure("2") do |config|
  NODES.each do |node|
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
      server.vm.provision "shell", inline: "sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config;systemctl reload sshd"
      server.vm.provision "k8-provision-prep", type: "shell", run: "never", path: "../COMMON/K8_provision_prep.sh", args: [SHARED_mount_point, node[:hostname], ENV_name]
      server.vm.provision "k8-init", type: "shell", run: "never", path: "../COMMON/K8_nodes_init.sh"
      server.vm.provision "k8-install-bins", type: "shell", run: "never", path: "../COMMON/K8_install_bins.sh"
      server.vm.provision "k8-create-cluster-cp", type: "shell", run: "never", path: "../COMMON/K8_create_cluster-cp.sh"
      server.vm.provision "k8-create-cluster-w", type: "shell", run: "never", path: "../COMMON/K8_create_cluster-w.sh"
      #server.vm.provision "k8-uninstall-bins", type: "shell", run: "never", path: "../COMMON/k8_uninstall_bins.sh"
      #server.vm.provision "k8-yum-packages", type: "shell", run: "never", path: "../COMMON/setup_yum.sh"
    end
  end
end
EOF

cat >> ./K8/$ENV_name/k8-init.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with k8-provision-prep
vagrant provision --provision-with k8-init
EOF

#cat >> ./K8/$ENV_name/k8-rescratch-bins+cluster.sh<<EOF
#echo "Executing \$0 \$@"
#vagrant provision --provision-with k8-uninstall-bins
#vagrant provision --provision-with k8-provision-prep
#vagrant provision --provision-with k8-install-bins
#vagrant provision --provision-with k8-create-cluster-cp
#EOF

cat >> ./K8/$ENV_name/k8-install-bins+cluster.sh<<EOF
echo "Executing \$0 \$@"
vagrant provision --provision-with k8-provision-prep
vagrant provision --provision-with k8-init
vagrant provision --provision-with k8-install-bins
vagrant provision --provision-with k8-create-cluster-cp
vagrant provision --provision-with k8-create-cluster-w
EOF

#cat >> ./K8/$ENV_name/k8-uninstall.sh<<EOF
#echo "Executing \$0 \$@"
#vagrant provision --provision-with k8-uninstall-bins
#EOF

chmod +x ./K8/$ENV_name/*.sh