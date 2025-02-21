echo "Executing step: COMMON/REDIS_provision_prep.sh"
echo " . Executing: $0 $@"
echo " . . Executing: cd ${1}/_PROVISION/${3}&&./INIT_host.sh"
cd ${1}/_PROVISION/${3}&&./INIT_host.sh