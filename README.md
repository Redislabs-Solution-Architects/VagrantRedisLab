# VagrantRedisLab
Vagrant-based Redis lab

It is a work in progress yet. This automation is built around Vagrant and Virtualbox for home labs, but it will also be usable for manual installations.
Considering that most of the customers we have are running RHEL, this tool kit is stuck to CentOS8s at the moment.
For a Vagrant Box you may consider something like https://www.ebay.com/itm/286036722832. Some extra RAM + HDD and you are good to go.

0. If installing to manually created hosts, make sure you have the following installed (might be ambigious though):
```
yum install -y screen iproute-tc jq htop python3-policycoreutils policycoreutils-python-utils boost-program-options cyrus-sasl checkpolicy python3-audit cyrus-sasl-plain cyrus-sasl-md5 python3-setools python3-libsemanage
```
1. Make a copy of either of RC* files (RC1 defaults to 3 node, RC2 - 5) and fill it. Run INIT.sh to initiate the env.
```
#./INIT.sh RC1RH8
node_names:rc1-rh8-node1 rc1-rh8-node2 rc1-rh8-node3
node_ips: 192.168.69.101 192.168.69.102 192.168.69.103
This is the temporary folder for all environment stuff. Do not modify anything here.
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./RES/COMMON/LOCAL_provision_prep.sh rc1-rh8-node1 ./SHARED /vagrant rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 RC1RH8
 . . Executing: mkdir -p ./SHARED/_PROVISION/RC1RH8
 . . Executing: echo "./$(hostname -s).sh" > ./SHARED/_PROVISION/RC1RH8/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/RC1RH8/rc1-rh8-node1.sh
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./RES/COMMON/LOCAL_provision_prep.sh rc1-rh8-node2 ./SHARED /vagrant rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 RC1RH8
 . . Executing: mkdir -p ./SHARED/_PROVISION/RC1RH8
 . . Executing: echo "./$(hostname -s).sh" > ./SHARED/_PROVISION/RC1RH8/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/RC1RH8/rc1-rh8-node2.sh
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./RES/COMMON/LOCAL_provision_prep.sh rc1-rh8-node3 ./SHARED /vagrant rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2 RC1RH8
 . . Executing: mkdir -p ./SHARED/_PROVISION/RC1RH8
 . . Executing: echo "./$(hostname -s).sh" > ./SHARED/_PROVISION/RC1RH8/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/RC1RH8/rc1-rh8-node3.sh
 #
```
2. Download RES package: cd SHARED/PACKAGES/RES/ && ./wget.sh
```
# cd SHARED/PACKAGES/RES/ && ./wget.sh
--2025-02-14 12:49:07--  https://s3.amazonaws.com/redis-enterprise-software-downloads/7.8.4/redislabs-7.8.4-66-rhel8-x86_64.tar
Resolving s3.amazonaws.com... 52.217.205.72, 52.217.195.96, 3.5.12.210, ...
Connecting to s3.amazonaws.com|52.217.205.72|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 312258560 (298M) [application/x-tar]
Saving to: ‘redislabs-7.8.4-66-rhel8-x86_64.tar’

redislabs-7.8.4-66-rhel8-x86_64.tar     100%[============================================================================>] 297.79M  20.8MB/s    in 14s

2025-02-14 12:49:21 (21.0 MB/s) - ‘redislabs-7.8.4-66-rhel8-x86_64.tar’ saved [312258560/312258560]
#
```
3. Once done, read Docs/Vagrant-based-installation.md or Manual-installation.md for further steps.


# VagrantRedisLab - K8

1. Make a copy of either of K8* files and fill it. Run INIT-K8.sh to initiate the env.
```
# ./INIT-K8.sh K8-18X
node_names:k8-18X-n1 k8-18X-n2 k8-18X-n3 k8-18X-n4
node_ips: 192.168.69.181 192.168.69.182 192.168.69.183 192.168.69.184
This is the temporary folder for all environment stuff. Do not modify anything here.
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./K8/COMMON/LOCAL_provision_prep.sh k8-18X-n1 ./SHARED /vagrant 192.168.69.181 192.168.69.2 K8-18X 192.168.69.181 k1813e.5044869ec5bc2393 10.69.0.0/16 192.168.69.189-192.168.69.189 6443 3
 . . Executing: mkdir -p ./SHARED/_PROVISION/K8-18X
 . . Creating ./SHARED/_PROVISION/K8-18X/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/K8-18X/k8-18X-n1.sh
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./K8/COMMON/LOCAL_provision_prep.sh k8-18X-n2 ./SHARED /vagrant 192.168.69.181 192.168.69.2 K8-18X 192.168.69.181 k1813e.5044869ec5bc2393 10.69.0.0/16 192.168.69.189-192.168.69.189 6443 3
 . . Executing: mkdir -p ./SHARED/_PROVISION/K8-18X
 . . Creating ./SHARED/_PROVISION/K8-18X/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/K8-18X/k8-18X-n2.sh
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./K8/COMMON/LOCAL_provision_prep.sh k8-18X-n3 ./SHARED /vagrant 192.168.69.181 192.168.69.2 K8-18X 192.168.69.181 k1813e.5044869ec5bc2393 10.69.0.0/16 192.168.69.189-192.168.69.189 6443 3
 . . Executing: mkdir -p ./SHARED/_PROVISION/K8-18X
 . . Creating ./SHARED/_PROVISION/K8-18X/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/K8-18X/k8-18X-n3.sh
Executing step: COMMON/LOCAL_provision_prep.sh
 . Executing: ./K8/COMMON/LOCAL_provision_prep.sh k8-18X-n4 ./SHARED /vagrant 192.168.69.181 192.168.69.2 K8-18X 192.168.69.181 k1813e.5044869ec5bc2393 10.69.0.0/16 192.168.69.189-192.168.69.189 6443 3
 . . Executing: mkdir -p ./SHARED/_PROVISION/K8-18X
 . . Creating ./SHARED/_PROVISION/K8-18X/INIT_host.sh
 . . Creating: ./SHARED/_PROVISION/K8-18X/k8-18X-n4.sh
#
```
2. Pack the entire content of SHARED folder and transfer to your four K8 hosts.

3. Installation flow: https://drive.google.com/file/d/1rvyekyB69SPGcvs7DWuIhSuQf95R9G1q/view?usp=drive_link