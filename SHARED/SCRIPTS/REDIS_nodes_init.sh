echo "Executing $0 $@"
echo " . Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
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

# configure resolv.conf to point own IP
source /root/redis-env-vars.sh
echo " . Update /etc/resolv.conf..."
rm -f /etc/resolv.conf
cat >/etc/resolv.conf <<EOF
options timeout:10
nameserver $REDIS_nameserver
EOF
chattr +i /etc/resolv.conf

# We need screen first to send scripts to background.
yum install -y screen
sed -i 's/metadata_expire.*/metadata_expire=6h/' /etc/dnf/dnf.conf

rm -f /root/REDIS_nodes_init.sh_FAIL /root/REDIS_nodes_init.sh_OK

echo " . Sending yum install to background..."
screen -dm bash -c " \
touch /root/REDIS_nodes_init.sh_running && \
yum install -y \
iproute-tc jq htop python3-policycoreutils policycoreutils-python-utils boost-program-options cyrus-sasl checkpolicy python3-audit cyrus-sasl-plain cyrus-sasl-md5 python3-setools python3-libsemanage \
> /root/REDIS_nodes_init.sh_log 2>&1 && \
rm -f /root/REDIS_nodes_init.sh_running && \
touch /root/REDIS_nodes_init.sh_OK || (touch /root/REDIS_nodes_init.sh_FAIL; rm -f /root/REDIS_nodes_init.sh_running)"
