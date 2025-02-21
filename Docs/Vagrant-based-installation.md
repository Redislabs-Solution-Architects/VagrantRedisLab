# VagrantRedisLab
Vagrant-based Redis lab

Vagrant part is stright forward. The INIT.sh creates environment folder in ./RES (E.g. ./RES/RC1RH8)

1. go to your ENV folder and inspect it.
```
# cd RES/RC1RH8/&&ls -l
total 4
-rw-r--r--    1 SUPERUSE UsersGrp      1669 Feb 21 10:10 Vagrantfile
-rwxr-xr-x    1 SUPERUSE UsersGrp       125 Feb 21 10:10 redis-init.sh
-rwxr-xr-x    1 SUPERUSE UsersGrp       236 Feb 21 10:10 redis-install-bins+cluster.sh
-rwxr-xr-x    1 SUPERUSE UsersGrp       246 Feb 21 10:10 redis-rescratch-bins+cluster.sh
-rwxr-xr-x    1 SUPERUSE UsersGrp        79 Feb 21 10:10 redis-uninstall.sh
#
```
2. Bring up your environment.
```
# vagrant status
Current machine states:

rc1-rh8-node1             not created (virtualbox)
rc1-rh8-node2             not created (virtualbox)
rc1-rh8-node3             not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
# vagrant up
Bringing machine 'rc1-rh8-node1' up with 'virtualbox' provider...
Bringing machine 'rc1-rh8-node2' up with 'virtualbox' provider...
Bringing machine 'rc1-rh8-node3' up with 'virtualbox' provider...
==> rc1-rh8-node1: Importing base box 'generic/centos8s'...
==> rc1-rh8-node1: Matching MAC address for NAT networking...
==> rc1-rh8-node1: Checking if box 'generic/centos8s' version '4.3.12' is up to date...
==> rc1-rh8-node1: Setting the name of the VM: rc1-rh8-node1
==> rc1-rh8-node1: Clearing any previously set network interfaces...
==> rc1-rh8-node1: Preparing network interfaces based on configuration...
    rc1-rh8-node1: Adapter 1: nat
    rc1-rh8-node1: Adapter 2: bridged
==> rc1-rh8-node1: Forwarding ports...
    rc1-rh8-node1: 22 (guest) => 2222 (host) (adapter 1)
==> rc1-rh8-node1: Running 'pre-boot' VM customizations...
==> rc1-rh8-node1: Booting VM...
==> rc1-rh8-node1: Waiting for machine to boot. This may take a few minutes...
    rc1-rh8-node1: SSH address: 127.0.0.1:2222
    rc1-rh8-node1: SSH username: vagrant
    rc1-rh8-node1: SSH auth method: private key
    rc1-rh8-node1:
    rc1-rh8-node1: Vagrant insecure key detected. Vagrant will automatically replace
    rc1-rh8-node1: this with a newly generated keypair for better security.
    rc1-rh8-node1:
    rc1-rh8-node1: Inserting generated public key within guest...
    rc1-rh8-node1: Removing insecure key from the guest if it's present...
    rc1-rh8-node1: Key inserted! Disconnecting and reconnecting using new SSH key...
==> rc1-rh8-node1: Machine booted and ready!
==> rc1-rh8-node1: Checking for guest additions in VM...
    rc1-rh8-node1: The guest additions on this VM do not match the installed version of
    rc1-rh8-node1: VirtualBox! In most cases this is fine, but in rare cases it can
    rc1-rh8-node1: prevent things such as shared folders from working properly. If you see
    rc1-rh8-node1: shared folder errors, please make sure the guest additions within the
    rc1-rh8-node1: virtual machine match the version of VirtualBox you have installed on
    rc1-rh8-node1: your host and reload your VM.
...
...
...
    rc1-rh8-node3:
    rc1-rh8-node3: Guest Additions Version: 6.1.30
    rc1-rh8-node3: VirtualBox Version: 7.0
==> rc1-rh8-node3: Setting hostname...
==> rc1-rh8-node3: Configuring and enabling network interfaces...
==> rc1-rh8-node3: Mounting shared folders...
    rc1-rh8-node3: /vagrant => C:/Users/SUPERUSER/Documents/Vagrant/SHARED
#
```
3. Install Redis and install cluster.
```
# ./redis-install-bins+cluster.sh
Executing ./redis-install-bins+cluster.sh
==> rc1-rh8-node1: Running provisioner: redis-provision-prep (shell)...
    rc1-rh8-node1: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250221-16824-n99vkz.sh
    rc1-rh8-node1: Executing step: COMMON/REDIS_provision_prep.sh
    rc1-rh8-node1:  . Executing: /tmp/vagrant-shell /vagrant rc1-rh8-node1 RC1RH8
    rc1-rh8-node1:  . . Executing: cd /vagrant/_PROVISION/RC1RH8&&./INIT_host.sh
    rc1-rh8-node1: Executing: ./rc1-rh8-node1.sh
    rc1-rh8-node1: Executing: /vagrant/SCRIPTS/REDIS_provision_prep.sh rc1.example.com redis@redis.com redis 192.168.69.101 192.168.69.2
    rc1-rh8-node1:  . . Creating /root/redis-env-vars.sh
..
..
..
==> rc1-rh8-node3: Running provisioner: redis-create-cluster (shell)...
    rc1-rh8-node3: Running: C:/Users/SUPERUSER/AppData/Roaming/MobaXterm/slash/tmp/vagrant-shell20250221-5968-os56am.sh
    rc1-rh8-node3: Executing step: COMMON/REDIS_create_cluster.sh
    rc1-rh8-node3:  . Executing: /tmp/vagrant-shell
    rc1-rh8-node3:  . . Executing: /root/_PROVISION/REDIS_create_cluster.sh
    rc1-rh8-node3: Executing /root/_PROVISION/REDIS_create_cluster.sh
    rc1-rh8-node3:  . . Testing rladmin status
    rc1-rh8-node3: /opt/redislabs/bin/rladmin
    rc1-rh8-node3: ERROR: invalid token 'status'
    rc1-rh8-node3:  . . Node not in a Redis cluster, continue...
    rc1-rh8-node3:  . . Running: rladmin cluster join nodes 192.168.69.101 username redis@redis.com password redis addr 192.168.69.103 external_addr 192.168.69.103
    rc1-rh8-node3: Joining cluster... ok
#
```
4. Done.

