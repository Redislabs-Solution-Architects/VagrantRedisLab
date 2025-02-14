k8Token=$2
nameserver=$3
podNETWORKcidr=$4
metalLB_IPRange=$5
controlPLANE_IP=$1
controlPLANE_PORT=$6

echo " [+] $(date) setup_cp.sh $controlPLANE_IP $k8Token $nameserver $podNETWORKcidr $metalLB_IPRange $controlPLANE_PORT"
echo " [+] $(date) Installing control-plane node..."

echo " [+] $(date) Enable ssh password authentication..."
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo " [+] $(date) Stop and Disable firewall..."
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
options timeout:30
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
# to make sure the folder is created.
systemctl start containerd
# apply default config
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
yum install -y kubelet kubeadm kubectl iproute-tc bash-completion screen
kubeadm config images pull
#systemctl start kubelet

# Set the --node-ip argument for kubelet
touch /etc/sysconfig/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$controlPLANE_IP" > /etc/sysconfig/kubelet
#systemctl daemon-reload
#systemctl restart kubelet
systemctl enable kubelet

echo " [+] $(date) Apply: kubeadm init --token $k8Token --apiserver-advertise-address $controlPLANE_IP --apiserver-bind-port $controlPLANE_PORT --pod-network-cidr=$podNETWORKcidr ..."
kubeadm init --token $k8Token --apiserver-advertise-address $controlPLANE_IP --apiserver-bind-port $controlPLANE_PORT --pod-network-cidr=$podNETWORKcidr
#sudo kubeadm init --apiserver-advertise-address=$CONTROL_IP --apiserver-cert-extra-sans=$CONTROL_IP --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap
# Copy the kube config file to home directories
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config
mkdir -p /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
#???????????????? Zachem?:
#cp /etc/kubernetes/admin.conf /vagrant
##########################kubectl rollout status deployment -n kube-system coredns
echo " [+] $(date) Apply: kubeadm init --token $k8Token --apiserver-advertise-address $controlPLANE_IP --apiserver-bind-port $controlPLANE_PORT --pod-network-cidr=$podNETWORKcidr ... Done."

echo " [+] $(date) Set aliases and TAB completion..."
echo "alias oc=kubectl" >> /root/.bashrc
echo "alias kc=kubectl" >> /root/.bashrc
echo 'source <(kubectl completion bash)' >>/root/.bashrc
echo 'complete -o default -F __start_kubectl kc' >> /root/.bashrc
echo 'complete -o default -F __start_kubectl oc' >> /root/.bashrc
echo " [+] $(date) Set aliases and TAB completion... Done."

#https://github.com/kubernetes-sigs/cri-tools/issues/153
echo " [+] $(date) Apply: crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock ..."
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock

# Install Calico - K8 requires CNI plugin for pod network: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
echo " [+] $(date) Install calico..."
#kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/release-v3.25/manifests/tigera-operator.yaml
cat <<EOF | tee /root/calico-installation.yaml
# This section includes base Calico installation configuration.
# For more information, see: https://docs.projectcalico.org/v3.19/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
apiVersion: operator.tigera.io/v1
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    bgp: Enabled  
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: $podNETWORKcidr
      encapsulation: IPIP
      natOutgoing: Enabled
      nodeSelector: all()
EOF
kubectl apply -f /root/calico-installation.yaml
echo " [+] $(date) Wait for calico-system controller pod..."
while [ $(kubectl get pods -n calico-system |grep 'calico-kube-controllers.* *1/1 *Running'|wc -l) -lt 1 ] ; do kubectl get pods -n calico-system -o wide; sleep 20; done; kubectl get pods -n calico-system -o wide
echo " [+] $(date) Install calico... Done."

echo " [+] $(date) Install calicoctl..."
# Install calicoctl https://docs.tigera.io/calico/latest/operations/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host
curl -L https://github.com/projectcalico/calico/releases/download/v3.25.0/calicoctl-linux-amd64 -o calicoctl
chmod +x calicoctl
mv calicoctl /usr/local/bin/
#sudo mkdir /etc/calico
#sudo cp /vagrant/calicoctl.cfg /etc/calico/
mkdir -p /etc/calico
cat <<EOF | tee /etc/calico/calicoctl.cfg 
apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "kubernetes"
  kubeconfig: "/root/.kube/config"
EOF

#cat <<EOF | tee /root/calico-bgpconfiguration.yaml
#apiVersion: projectcalico.org/v3
#kind: BGPConfiguration
#metadata:
#  name: default
#spec:
#  logSeverityScreen: Info
#  nodeToNodeMeshEnabled: true
#  asNumber: 65000
#
#---
#apiVersion: projectcalico.org/v3
#kind: BGPPeer
#metadata:
#  name: my-global-peer
#spec:
#  peerIP: $3
#  asNumber: 65000
#EOF

# Configure Calico for BGP peering. not sure if we need it here.
#calicoctl apply -f /root/calico-bgpconfiguration.yaml

# Create ConfigMap for ingress controller
#kubectl create configmap haproxy-kubernetes-ingress
echo " [+] $(date) Install calicoctl... Done."

kubectl get pods -A -o wide

# Should leave below in background wait till all 3 nodes are ready or it will take forever to get LB and ingress up and running.
cat <<EOF_BKG | tee /root/setup_cp_bkg.sh
echo " [+] \$(date) Wait for a wroker nodes Ready..."
while [ \$(kubectl get nodes|grep -v control-plane|grep -w Ready|wc -l) -lt 3 ] ; do kubectl get nodes -o wide; sleep 20; done; kubectl get nodes -o wide

#wait for 60 second to make sure all processes are settled.
sleep 60

echo " [+] \$(date) Install https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
echo " [+] \$(date) Wait for metallb-system controller pod..."
while [ \$(kubectl get pods -n metallb-system |grep 'controller.* *1/1 *Running'|wc -l) -lt 1 ] ; do kubectl get pods -n metallb-system -o wide; sleep 20; done; kubectl get pods -n metallb-system -o wide
echo " [+] \$(date) Install https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml... Done."

kubectl get pods -A -o wide

cat <<EOF | tee /root/\$1-metalLB.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - \$2
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
EOF
kubectl apply -f /root/\$1-metalLB.yaml

sleep 30

echo " [+] \$(date) Install ingress-nginx..."
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
#Enable SSL passthrough, see https://redis.io/docs/latest/operate/kubernetes/networking/ingress/#prerequisites
curl -o ingress-nginx-deploy.yaml  https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
sed -i "/- \/nginx-ingress-controller/a\ \ \ \ \ \ \ \ - --enable-ssl-passthrough" ./ingress-nginx-deploy.yaml
kubectl apply -f ./ingress-nginx-deploy.yaml
echo " [+] \$(date) Wait for ingress-nginx controller pod..."
while [ \$(kubectl get pods -n ingress-nginx |grep 'ingress-nginx-controller.* *1/1 *Running'|wc -l) -lt 1 ] ; do kubectl get pods -n ingress-nginx -o wide; sleep 20; done; kubectl get pods -n ingress-nginx -o wide
echo " [+] \$(date) Install ingress-nginx... Done."

kubectl get pods -A -o wide
EOF_BKG

echo " [+] $(date) Evoking in background: screen -dm bash -c \"/root/setup_cp_bkg.sh $controlPLANE_IP $metalLB_IPRange > /root/metalLB+ingress.log\" ... "
chmod +x /root/setup_cp_bkg.sh
screen -dm bash -c "/root/setup_cp_bkg.sh $controlPLANE_IP $metalLB_IPRange > /root/metalLB+ingress.log"
