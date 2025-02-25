echo "Executing $0 $@"
sleep 2
source /root/k8-env-vars.sh

hostname -I|grep $controlPLANE_IP;hostname_result=$?
#echo $hostname_result
test $hostname_result -eq 0 && echo " . . Control Plane node. You shall not run this script on the Control Plane nodes. Exiting..." || \
echo " . . Worker node. Continue..."

test $hostname_result -eq 0 && exit 0

#########################################################

# Need this module in Kernel
echo br_netfilter > /etc/modules-load.d/br_netfilter.conf
systemctl restart systemd-modules-load.service
# it should be 1 by default, but just in case.
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
# Allow IP forwarding.
echo 1 > /proc/sys/net/ipv4/ip_forward

until [ "$(curl -k https://$controlPLANE_IP:$controlPLANE_PORT/livez)" == "ok" ]; do echo "Waiting for Control Plane $controlPLANE_IP:$controlPLANE_PORT..."; curl -k https://192.168.69.81:6443/livez?verbose; sleep 10; done

# Just to be on a safe side since it may fluctuate sometimes.
sleep 5

touch /etc/sysconfig/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$K8_self_IP" > /etc/sysconfig/kubelet

systemctl enable kubelet
echo "Ececuting: kubeadm join --token $k8Token $controlPLANE_IP:$controlPLANE_PORT --discovery-token-unsafe-skip-ca-verification"
kubeadm join --token $k8Token $controlPLANE_IP:$controlPLANE_PORT --discovery-token-unsafe-skip-ca-verification

#https://github.com/kubernetes-sigs/cri-tools/issues/153
echo " [+] $(date) Apply: crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock ..."
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock