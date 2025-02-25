echo "Executing $0 $@"
sleep 2
source /root/k8-env-vars.sh

hostname -I|grep $controlPLANE_IP;hostname_result=$?
#echo $hostname_result
test $hostname_result -eq 0 && echo " . . Control Plane node. Continue..." || \
echo " . . You shall not run this script on the non Control Plane nodes. Exiting."

test $hostname_result -eq 0 || exit 0

#########################################################

# We need UI/XRDP/redis-cli on CP to access ingresses.
cat <<EOF_BKG | tee /root/setup_XFCE_bkg.sh
yum -y groupinstall xfce
yum install -y chromium nautilus gedit xrdp
systemctl enable xrdp
systemctl start xrdp
systemctl status xrdp
yum install -y https://rpmfind.net/linux/remi/enterprise/8/modular/x86_64/redis-7.2.7-1.el8.remi.x86_64.rpm
EOF_BKG

kubeadm config images pull --kubernetes-version stable-1.29

echo " [+] $(date) Evoking in background: screen -dm bash -c \"/root/setup_XFCE_bkg.sh > /root/setup_XFCE_bkg.log\" ... "
chmod +x /root/setup_XFCE_bkg.sh
screen -dm bash -c "/root/setup_XFCE_bkg.sh > /root/setup_XFCE_bkg.log"

# Need this module in Kernel
echo br_netfilter > /etc/modules-load.d/br_netfilter.conf
systemctl restart systemd-modules-load.service

# it should be 1 by default, but just in case.
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
# Allow IP forwarding.
echo 1 > /proc/sys/net/ipv4/ip_forward

# Set the --node-ip argument for kubelet
touch /etc/sysconfig/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$controlPLANE_IP" > /etc/sysconfig/kubelet
systemctl enable kubelet

echo " [+] $(date) Apply: kubeadm init --token $k8Token --apiserver-advertise-address $controlPLANE_IP --apiserver-bind-port $controlPLANE_PORT --pod-network-cidr=$podNETWORKcidr ..."
kubeadm init --kubernetes-version stable-1.29 --token $k8Token --apiserver-advertise-address $controlPLANE_IP --apiserver-bind-port $controlPLANE_PORT --pod-network-cidr=$podNETWORKcidr

# Copy the kube config file to home directories
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config
#mkdir -p /home/vagrant/.kube
#cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
#chown -R vagrant:vagrant /home/vagrant/.kube
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

echo " [+] $(date) Install calicoctl... Done."

kubectl get pods -A -o wide

# Should leave below in background wait till all 3 nodes are ready or it will take forever to get LB and ingress up and running.
cat <<EOF_BKG | tee /root/setup_cp_bkg.sh
echo " [+] \$(date) Wait for a wroker nodes Ready..."
while [ \$(kubectl get nodes|grep -v control-plane|grep -w Ready|wc -l) -lt $worker_node_count ] ; do kubectl get nodes -o wide; sleep 20; done; kubectl get nodes -o wide

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
touch /root/setup_cp_bkg.sh.DONE
EOF_BKG

echo " [+] $(date) Evoking in background: screen -dm bash -c \"/root/setup_cp_bkg.sh $controlPLANE_IP $metalLB_IPRange > /root/metalLB+ingress.log\" ... "
chmod +x /root/setup_cp_bkg.sh
screen -dm bash -c "/root/setup_cp_bkg.sh $controlPLANE_IP $metalLB_IPRange > /root/metalLB+ingress.log"

