echo "Executing $0 $@"
vagrant provision --provision-with redis-provision-prep && \
vagrant provision --provision-with redis-init && \
vagrant provision --provision-with redis-install-bins && \
vagrant provision --provision-with redis-create-cluster
