# VagrantRedisLab
Vagrant-based Redis lab

It is a work in progress yet. This automation is built around Vagrant and Virtualbox for home labs, but it will also be usable for Vagrant-less installations. You'll need Vagrant installed anyway (just 1G of your drive).

0. If installing to manually created hosts, make sure you have the following installed:
```
yum install -y screen iproute-tc jq htop python3-policycoreutils policycoreutils-python-utils boost-program-options cyrus-sasl checkpolicy python3-audit cyrus-sasl-plain cyrus-sasl-md5 python3-setools python3-libsemanage
```

1. Run INIT.sh to initiate the env.
```
./INIT.sh
++ mkdir -p ./SHARED/_PROVISION
++ cat
++ tee ./SHARED/_PROVISION/README.txt
This is the temporary folder for all environment stuff. Do not modify anything here.
```
2. Download RES package: cd SHARED/PACKAGES/RES/ && ./wget.sh
```
cd SHARED/PACKAGES/RES/ && ./wget.sh
--2025-02-14 12:49:07--  https://s3.amazonaws.com/redis-enterprise-software-downloads/7.8.4/redislabs-7.8.4-66-rhel8-x86_64.tar
Resolving s3.amazonaws.com... 52.217.205.72, 52.217.195.96, 3.5.12.210, ...
Connecting to s3.amazonaws.com|52.217.205.72|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 312258560 (298M) [application/x-tar]
Saving to: ‘redislabs-7.8.4-66-rhel8-x86_64.tar’

redislabs-7.8.4-66-rhel8-x86_64.tar     100%[============================================================================>] 297.79M  20.8MB/s    in 14s

2025-02-14 12:49:21 (21.0 MB/s) - ‘redislabs-7.8.4-66-rhel8-x86_64.tar’ saved [312258560/312258560]

```
3. Modify Vagrantfile: cd RES/RC1RH8/ && vi Vagrantfile

4. Evoke: vagrant up to create Centos8 VMs ready for your Redis cluster installation.
```
vagrant up
Bringing machine 'rc2-rh8-node1' up with 'virtualbox' provider...
Bringing machine 'rc2-rh8-node2' up with 'virtualbox' provider...
Bringing machine 'rc2-rh8-node3' up with 'virtualbox' provider...
Bringing machine 'rc2-rh8-node4' up with 'virtualbox' provider...
Bringing machine 'rc2-rh8-node5' up with 'virtualbox' provider...
==> rc2-rh8-node1: Importing base box 'generic/centos8s'...
==> rc2-rh8-node1: Matching MAC address for NAT networking...
==> rc2-rh8-node1: Checking if box 'generic/centos8s' version '4.3.12' is up to date...
...
...
...
    rc2-rh8-node5:  . Update /etc/resolv.conf...
    rc2-rh8-node5: Retype new password:
==> rc2-rh8-node5: Running provisioner: redis-provision-prep (shell)...
    rc2-rh8-node5: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250214-21492-lpofy5.sh
    rc2-rh8-node5: Executing: /vagrant/_PROVISION/rc2-rh8-node5.sh
    rc2-rh8-node5: Executing /vagrant/SCRIPTS/REDIS_provision_prep.sh
    rc2-rh8-node5:  . . Creating /root/redis-env-vars.sh
```

5. If you'd run it with provision_type="local" option, then all files required for installation are precoocked and ready to be copied to host. Take a copy of SHARED folder content to every host you have or have it mounted over any available flavour utility to mount it to all hosts. E.g.
```
[root@rc2-rh8-node1 vagrant]# pwd
/vagrant
[root@rc2-rh8-node1 vagrant]# ls -l
total 12
drwxrwxrwx. 1 vagrant vagrant 4096 Feb 14 16:31 CURLs
drwxrwxrwx. 1 vagrant vagrant    0 Feb 14 16:25 PACKAGES
drwxrwxrwx. 1 vagrant vagrant 4096 Feb 14 21:26 _PROVISION
drwxrwxrwx. 1 vagrant vagrant 4096 Feb 14 16:25 SCRIPTS
[root@rc2-rh8-node1 vagrant]#
```
5.1 Get inside of the _PROVISION folder and run INIT:
```
[root@rc2-rh8-node1 vagrant]# cd _PROVISION/
[root@rc2-rh8-node1 _PROVISION]# ./INIT_host.sh
Executing: ./rc2-rh8-node1.sh
Executing /vagrant/SCRIPTS/REDIS_provision_prep.sh
 . . Creating /root/redis-env-vars.sh
[root@rc2-rh8-node1 _PROVISION]#
```
5.2 Your host is ready to deploy Redis.
```
[root@rc2-rh8-node1 _PROVISION]# cd /root/
[root@rc2-rh8-node1 ~]# ls -l
total 4
drwxr-xr-x. 2 root root 121 Feb 14 23:33 _PROVISION
-rw-r--r--. 1 root root 231 Feb 14 23:33 redis-env-vars.sh
[root@rc2-rh8-node1 ~]# cd _PROVISION/
[root@rc2-rh8-node1 _PROVISION]# ls -l
total 0
lrwxrwxrwx. 1 root root 36 Feb 14 23:33 rc2-rh8-node1.sh -> /vagrant/_PROVISION/rc2-rh8-node1.sh
lrwxrwxrwx. 1 root root 40 Feb 14 23:33 REDIS_create_cluster.sh -> /vagrant/SCRIPTS/REDIS_create_cluster.sh
lrwxrwxrwx. 1 root root 38 Feb 14 23:33 REDIS_install_bins.sh -> /vagrant/SCRIPTS/REDIS_install_bins.sh
lrwxrwxrwx. 1 root root 40 Feb 14 23:33 REDIS_uninstall_bins.sh -> /vagrant/SCRIPTS/REDIS_uninstall_bins.sh
[root@rc2-rh8-node1 _PROVISION]#
```
5.3 Install binaries and watch log file for installation process:
```
[root@rc2-rh8-node1 _PROVISION]# ./REDIS_install_bins.sh
Executing ./REDIS_install_bins.sh
 . . Running REDIS_install_bins.sh
[root@rc2-rh8-node1 _PROVISION]# ls -l ../RES_install.sh_log
-rw-r--r--. 1 root root 3552 Feb 14 23:35 ../RES_install.sh_log
[root@rc2-rh8-node1 _PROVISION]#
[root@rc2-rh8-node1 _PROVISION]# tail ../RES_install.sh_log
Summary:
-------
ALL TESTS PASSED.


2025-02-14 23:38:09.546 [!] Please logout and login again to make sure all environment changes are applied.
2025-02-14 23:38:09.547 [!] Point your browser at the following URL to continue:
2025-02-14 23:38:09.549 [!] https://<name or IP address of the machine with Redis Enterprise Software installed>:8443
2025-02-14 23:38:09.550 [.] Fixing file permissions
2025-02-14 23:38:09.578 [!] Installation complete.
[root@rc2-rh8-node1 _PROVISION]#
```
5.3 Start from the "first_node_ip" host and create Redis cluster first node:
```
[root@rc2-rh8-node1 _PROVISION]# ./REDIS_create_cluster.sh
Executing ./REDIS_create_cluster.sh
 . . Testing rladmin status
/opt/redislabs/bin/rladmin
ERROR: invalid token 'status'
 . . Node not in a Redis cluster, continue...
10.0.2.15 192.168.69.201
 . . Running: rladmin cluster create name rc2.example.com username redis@redis.com password redis addr 192.168.69.201 external_addr 192.168.69.201
Creating a new cluster... ok
[root@rc2-rh8-node1 _PROVISION]#
```
5.4 Repeat the same steps on th rest of nodes.

6. If you are using Vagrant and Virtualbox in your own LAB, then upon vagrant up completion you'll have your VMs up and running ready to deploy Redis cluster.

6.1 It is already applied, but you can refresh your Redis env:
```
/home/mobaxterm/Vagrant/RES/RC2RH8# ls -l
total 3
-rwx------    1 SUPERUSE UsersGrp      2396 Feb 14 11:41 Vagrantfile
-rwx------    1 SUPERUSE UsersGrp       242 Feb 14 11:25 redis-rescratch-bins+cluster.sh

/home/mobaxterm/Vagrant/RES/RC2RH8# vagrant provision --provision-with redis-provision-prep
Executing ../COMMON/VAGRANT_provision_prep.sh
...
...
...
==> rc2-rh8-node5: Running provisioner: redis-provision-prep (shell)...
    rc2-rh8-node5: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250214-21720-frdl6p.sh
    rc2-rh8-node5: Executing: /vagrant/_PROVISION/rc2-rh8-node5.sh
    rc2-rh8-node5: Executing: /vagrant/_PROVISION/rc2-rh8-node5.sh
    rc2-rh8-node5: Executing /vagrant/SCRIPTS/REDIS_provision_prep.sh
    rc2-rh8-node5:  . . Creating /root/redis-env-vars.sh
/home/mobaxterm/Vagrant/RES/RC2RH8#
```

6.2 Install Redis binaries:
```
/home/mobaxterm/Vagrant/RES/RC2RH8# vagrant provision --provision-with redis-install-bins
Executing ../COMMON/VAGRANT_provision_prep.sh
...
...
...
==> rc2-rh8-node5: Running provisioner: redis-install-bins (shell)...
    rc2-rh8-node5: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250214-11488-vw6a60.sh
    rc2-rh8-node5: Executing: /root/_PROVISION/REDIS_install_bins.sh
    rc2-rh8-node5: Executing /root/_PROVISION/REDIS_install_bins.sh
    rc2-rh8-node5:  . . Running REDIS_install_bins.sh
/home/mobaxterm/Vagrant/RES/RC2RH8#
```

6.3 Create Redis cluster:
```
/home/mobaxterm/Vagrant/RES/RC2RH8# vagrant provision --provision-with redis-create-cluster
Executing ../COMMON/VAGRANT_provision_prep.sh
...
...
...
==> rc2-rh8-node5: Running provisioner: redis-create-cluster (shell)...
    rc2-rh8-node5: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250214-19676-a8ryib.sh
    rc2-rh8-node5: Executing: /root/_PROVISION/REDIS_create_cluster.sh
    rc2-rh8-node5: Executing /root/_PROVISION/REDIS_create_cluster.sh
    rc2-rh8-node5:  . . Testing rladmin status
    rc2-rh8-node5: /opt/redislabs/bin/rladmin
    rc2-rh8-node5: ERROR: invalid token 'status'
    rc2-rh8-node5:  . . Node not in a Redis cluster, continue...
    rc2-rh8-node5:  . . Running: rladmin cluster join nodes 192.168.69.201 username redis@redis.com password redis addr 192.168.69.205 external_addr 192.168.69.205
    rc2-rh8-node5: Joining cluster... ok
/home/mobaxterm/Vagrant/RES/RC2RH8#
```
6.4 Re-scratch the etire Redis cluster:
```
/home/mobaxterm/Vagrant/RES/RC2RH8# ./redis-rescratch-bins+cluster.sh
Executing ./redis-rescratch-bins+cluster.sh
bash.exe: warning: could not find /tmp, please create!
Executing ../COMMON/VAGRANT_provision_prep.sh
...
...
...
==> rc2-rh8-node5: Running provisioner: redis-create-cluster (shell)...
    rc2-rh8-node5: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250214-20112-9near4.sh
    rc2-rh8-node5: Executing: /root/_PROVISION/REDIS_create_cluster.sh
    rc2-rh8-node5: Executing /root/_PROVISION/REDIS_create_cluster.sh
    rc2-rh8-node5:  . . Testing rladmin status
    rc2-rh8-node5: /opt/redislabs/bin/rladmin
    rc2-rh8-node5: ERROR: invalid token 'status'
    rc2-rh8-node5:  . . Node not in a Redis cluster, continue...
    rc2-rh8-node5:  . . Running: rladmin cluster join nodes 192.168.69.201 username redis@redis.com password redis addr 192.168.69.205 external_addr 192.168.69.205
    rc2-rh8-node5: Joining cluster... ok
/home/mobaxterm/Vagrant/RES/RC2RH8#
```
