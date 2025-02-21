echo "Executing $0 $@"
vagrant provision --provision-with redis-provision-prep
vagrant provision --provision-with redis-init
