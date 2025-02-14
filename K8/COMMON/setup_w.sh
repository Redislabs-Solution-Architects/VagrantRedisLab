k8Token=$2
nameserver=$3
controlPLANE_IP_PORT=$4
Self_IP=$1

echo " [+] $(date) setup_w.sh $Self_IP $k8Token $nameserver $controlPLANE_IP_PORT"
echo " [+] $(date) Installing worker..."

echo " [+] $(date) Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo " [+] $(date) Stop and Disable firewall"
#systemctl disable --now ufw
systemctl stop firewalld
systemctl disable firewalld

echo " [+] $(date) Set root password"
echo -e "redis\nredis" | passwd root

# Disable swap, as required by kubelet
echo " [+] $(date) Disable swap, as required by kubelet..."
swapoff -a
sed -i '/swap/d' /etc/fstab

setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#echo " [+] $(date) Disable NetworkManager..."
#systemctl stop NetworkManager
#systemctl disable NetworkManager

# switch to vault repo
#cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo " [+] $(date) Set /etc/resolv.conf..."
rm -f /etc/resolv.conf
cat >/etc/resolv.conf<<EOF
options timeout:10
nameserver $nameserver
EOF
chattr +i /etc/resolv.conf

# Docker is not longer in charge, we can skip its installation.
echo " [+] $(date) Add docker/containerd/etc..."
yum config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker
systemctl enable docker
# Change Docker cgroup driver to systemd
cat <<EOF | tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl restart docker
systemctl start containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo " [+] $(date) Install and configure Kubernetes..."
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
yum install -y kubelet kubeadm kubectl iproute-tc
kubeadm config images pull

#systemctl start kubelet
touch /etc/sysconfig/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$Self_IP" > /etc/sysconfig/kubelet
#systemctl daemon-reload
#systemctl restart kubelet

systemctl enable kubelet
#kubeadm init --token $2 --apiserver-advertise-address $1 --pod-network-cidr=$4
kubeadm join --token $k8Token $controlPLANE_IP_PORT --discovery-token-unsafe-skip-ca-verification
# # Copy the kube config file to home directories
# mkdir -p /root/.kube
# cp /etc/kubernetes/admin.conf /root/.kube/config
# chown root:root /root/.kube/config
# mkdir -p /home/vagrant/.kube
# cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
# chown -R vagrant:vagrant /home/vagrant/.kube
# #???????????????? Zachem?
# cp /etc/kubernetes/admin.conf /vagrant

## Set the --node-ip argument for kubelet
#touch /etc/default/kubelet
#echo "KUBELET_EXTRA_ARGS=--node-ip=$1" > /etc/default/kubelet
#systemctl daemon-reload
#systemctl restart kubelet

#https://github.com/kubernetes-sigs/cri-tools/issues/153
echo " [+] $(date) Apply: crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock ..."
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock