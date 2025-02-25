echo "Executing $0 $@"
echo " . Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo " . Stop and Disable firewall"
systemctl stop firewalld
systemctl disable firewalld

echo " . Set root password"
echo -e "redis\nredis" | passwd root

# switch to vault repo
#cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

#yum install -y screen iproute-tc jq htop python3-policycoreutils policycoreutils-python-utils boost-program-options cyrus-sasl checkpolicy python3-audit cyrus-sasl-plain cyrus-sasl-md5 python3-setools python3-libsemanage

# configure resolv.conf to point own IP
source /root/k8-env-vars.sh
echo " . Update /etc/resolv.conf..."
rm -f /etc/resolv.conf
cat >/etc/resolv.conf<<EOF
options timeout:10
nameserver $K8_nameserver
EOF
chattr +i /etc/resolv.conf
