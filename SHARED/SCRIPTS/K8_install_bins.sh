# Disable swap, as required by kubelet
echo " [+] $(date) Disable swap, as required by kubelet..."
swapoff -a
sed -i '/swap/d' /etc/fstab

# need to double check if we can use it enabled.keep it for a while.
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Docker is not longer in charge, we can skip its installation.
echo " [+] $(date) Add containerd..."
yum config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
# containerd is part od docker repo and required by K8 cluster. Docker is no longer in charge.
yum install -y containerd.io htop screen #docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
#systemctl start docker
#systemctl enable docker
# Change Docker cgroup driver to systemd
#cat <<EOF | tee /etc/docker/daemon.json
#{
#    "exec-opts": ["native.cgroupdriver=systemd"]
#}
#EOF
#systemctl restart docker

# to make sure the folder is created.
systemctl start containerd
# apply default config
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo " [+] $(date) Install Kubernetes binaries..."
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
#exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
# K8 requires iproute-tc
yum install -y kubelet kubeadm kubectl iproute-tc bash-completion
kubeadm config images pull --kubernetes-version stable-1.29