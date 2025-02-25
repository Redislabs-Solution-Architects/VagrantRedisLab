echo "Executing step: COMMON/K8_provision_prep.sh"
echo " . Executing: $0 $@"
echo " . . Executing: cd ${1}/_PROVISION/${3}&&./INIT_host.sh"
cd ${1}/_PROVISION/${3}&&./INIT_host.sh