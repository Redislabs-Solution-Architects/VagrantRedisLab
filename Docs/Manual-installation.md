# VagrantRedisLab

0. Take the entire SHARED folder to your host:
```
[root@rc1-rh8-node1 SHARED]# pwd
/root/SHARED
[root@rc1-rh8-node1 SHARED]# ls -l
total 8
drwxrwxrwx. 1 vagrant vagrant 4096 Feb 14 16:31 CURLs
drwxrwxrwx. 1 vagrant vagrant    0 Feb 14 16:25 PACKAGES
drwxrwxrwx. 1 vagrant vagrant    0 Feb 20 22:04 _PROVISION
drwxrwxrwx. 1 vagrant vagrant    0 Feb 21 13:08 RLADMIN
drwxrwxrwx. 1 vagrant vagrant 4096 Feb 19 17:59 SCRIPTS
[root@rc1-rh8-node1 SHARED]#
```
1. Run ./INIT_host.sh to instantiate the env.
```
[root@rc1-rh8-node1 ~]# /root/SHARED/_PROVISION/RC1RH8/INIT_host.sh
Executing: ./rc1-rh8-node1.sh
Executing: /root/SHARED/SCRIPTS/REDIS_provision_prep.sh rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 /root/SHARED
 . . Creating /root/redis-env-vars.sh
[root@rc1-rh8-node1 ~]#
```
It creates:
```
[root@rc1-rh8-node1 ~]# pwd
/root
[root@rc1-rh8-node1 ~]# tree
.
├── _PROVISION
│   ├── rc1-rh8-node1.sh -> /root/SHARED/_PROVISION/RC1RH8/rc1-rh8-node1.sh
│   ├── REDIS_create_cluster.sh -> /root/SHARED/SCRIPTS/REDIS_create_cluster.sh
│   ├── REDIS_install_bins.sh -> /root/SHARED/SCRIPTS/REDIS_install_bins.sh
│   ├── REDIS_nodes_init.sh -> /root/SHARED/SCRIPTS/REDIS_nodes_init.sh
│   └── REDIS_uninstall_bins.sh -> /root/SHARED/SCRIPTS/REDIS_uninstall_bins.sh
└── redis-env-vars.sh
```

2. Execute /root/_PROVISION/REDIS_nodes_init.sh (You may want to inspect script first)
```

[root@rc1-rh8-node1 RC1RH8]# /root/_PROVISION/REDIS_nodes_init.sh
Executing /root/_PROVISION/REDIS_nodes_init.sh
 . Enable ssh password authentication
 . Stop and Disable firewall
Removed /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
 . Set root password
Changing password for user root.
New password: BAD PASSWORD: The password is shorter than 8 characters
Retype new password: passwd: all authentication tokens updated successfully.
CentOS Stream 8 - AppStream                                                                                                                          17 MB/s |  29 MB     00:01
CentOS Stream 8 - BaseOS                                                                                                                             14 MB/s |  10 MB     00:00
CentOS Stream 8 - Extras                                                                                                                             87 kB/s |  18 kB     00:00
CentOS Stream 8 - Extras common packages                                                                                                             39 kB/s | 8.0 kB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                                                                                      4.6 MB/s |  14 MB     00:02
Extra Packages for Enterprise Linux 8 - Next - x86_64                                                                                               247 kB/s | 232 kB     00:00
...
...
  Verifying        : policycoreutils-2.9-24.el8.x86_64                                                                                                                        17/17

Upgraded:
  policycoreutils-2.9-26.el8.x86_64
Installed:
  boost-program-options-1.66.0-13.el8.x86_64     checkpolicy-2.9-1.el8.x86_64                       cyrus-sasl-2.1.27-6.el8_5.x86_64     cyrus-sasl-md5-2.1.27-6.el8_5.x86_64
  cyrus-sasl-plain-2.1.27-6.el8_5.x86_64         htop-3.2.1-1.el8.x86_64                            iproute-tc-6.2.0-5.el8.x86_64        jq-1.6-9.el8.x86_64
  oniguruma-6.8.2-3.el8.x86_64                   policycoreutils-python-utils-2.9-26.el8.noarch     python3-audit-3.1.2-1.el8.x86_64     python3-libsemanage-2.9-9.el8.x86_64
  python3-policycoreutils-2.9-26.el8.noarch      python3-setools-4.3.0-5.el8.x86_64                 screen-4.6.2-12.el8.x86_64

Complete!
 . Update /etc/resolv.conf...
[root@rc1-rh8-node1 RC1RH8]#
```
3. Install Redis binaries:
```
[root@rc1-rh8-node1 ~]# # /root/_PROVISION/REDIS_install_bins.sh&&ls -lrt&&sleep 2&&tail -f RES_install.sh_log
Executing /root/_PROVISION/REDIS_install_bins.sh
/usr/bin/which: no rladmin in (/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin)
 . . Running REDIS_install_bins.sh
total 4
drwxrwxrwx. 1 vagrant vagrant   0 Feb 21 13:07 SHARED
-rw-r--r--. 1 root    root    313 Feb 21 18:12 redis-env-vars.sh
drwxr-xr-x. 2 root    root    148 Feb 21 18:12 _PROVISION
Executing ./RES_install.sh redislabs-6.2.18-70-rhel8-x86_64.tar
...
...
ALL TESTS PASSED.


2025-02-21 17:54:38.174 [!] Please logout and login again to make sure all environment changes are applied.
2025-02-21 17:54:38.176 [!] Point your browser at the following URL to continue:
2025-02-21 17:54:38.184 [!] https://10.0.2.15:8443
2025-02-21 17:54:38.186 [!] Fixing file permissions.
2025-02-21 17:54:38.225 [!] Installation complete.
^C
[root@rc1-rh8-node1 ~]#
```

4. Create Redis cluster. Make sure it complete on the first node before executing on the rest.
```
[root@rc1-rh8-node1 ~]#  /root/_PROVISION/REDIS_create_cluster.sh
Executing /root/_PROVISION/REDIS_create_cluster.sh
 . . Testing rladmin status
/opt/redislabs/bin/rladmin
ERROR: invalid token 'status'
 . . Node not in a Redis cluster, continue...
10.0.2.15 192.168.69.101
 . . Running: rladmin cluster create name rc1.example.com username redis@redis.com password redis addr 192.168.69.101 external_addr 192.168.69.101
Creating a new cluster... ok
[root@rc1-rh8-node1 ~]#
```

5. You can do it all in one shot (make sure you have a delay after 1st node execution, it should be ahead of the rest of nodes):
```
[root@rc1-rh8-node1 ~]# ./SHARED/_PROVISION/RC1RH8/DOitALL.sh
Executing: ./SHARED/_PROVISION/RC1RH8/DOitALL.sh
Executing: ./rc1-rh8-node1.sh
Executing: /root/SHARED/SCRIPTS/REDIS_provision_prep.sh rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 /root/SHARED
 . . Creating /root/redis-env-vars.sh
Executing: ./rc1-rh8-node1.sh
Executing: /root/SHARED/SCRIPTS/REDIS_provision_prep.sh rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 /root/SHARED
 . . Creating /root/redis-env-vars.sh
Executing /root/_PROVISION/REDIS_nodes_init.sh
 . Enable ssh password authentication
 . Stop and Disable firewall
...
...
2025-02-21 18:38:11.105 [$] executing: 'yum install -y redislabs-6.2.18-70.rhel8.x86_64.rpm'

 . . Testing rladmin status
/opt/redislabs/bin/rladmin
ERROR: invalid token 'status'
 . . Node not in a Redis cluster, continue...
10.0.2.15 192.168.69.101
 . . Running: rladmin cluster create name rc1.example.com username redis@redis.com password redis addr 192.168.69.101 external_addr 192.168.69.101
Creating a new cluster... ok
[root@rc1-rh8-node1 ~]#
```