echo "Executing $0 $@"
vagrant provision --provision-with k8-uninstall-bins
vagrant provision --provision-with k8-provision-prep
vagrant provision --provision-with k8-install-bins
vagrant provision --provision-with k8-create-cluster-cp
