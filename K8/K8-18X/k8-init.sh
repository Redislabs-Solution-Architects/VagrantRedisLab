echo "Executing $0 $@"
vagrant provision --provision-with k8-provision-prep
vagrant provision --provision-with k8-init
