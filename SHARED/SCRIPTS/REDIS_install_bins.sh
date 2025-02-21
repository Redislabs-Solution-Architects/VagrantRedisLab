echo "Executing $0 $@"

which rladmin;rladmin_result=$?
test $rladmin_result -eq 0 && echo " . . ERROR: rladmin exists, exiting..."
test $rladmin_result -eq 0 && exit 0

sleep 2
test -f /root/RES_install.sh_running && echo 'The test -f /root/RES_install.sh_running is positive. Exit.'
test -f /root/RES_install.sh_running && exit 0

test -f /root/rl_uninstall.sh_running && echo 'The test -f /root/rl_uninstall.sh_running is positive. Wait.'
while test -f /root/rl_uninstall.sh_running; do echo "$(date) - Exists /root/rl_uninstall.sh_running. sleep 20."; echo; tail -1 /root/rl_uninstall.sh_log; echo; sleep 20; done

echo " . . Running REDIS_install_bins.sh"
source /root/redis-env-vars.sh
cd /$REDIS_SHARED_mount_point/PACKAGES/RES/
#./RES_install.sh $(ls *.tar|tail -1)
rm -f /root/RES_install.sh_running
rm -f /root/RES_install.sh_OK
screen -dm bash -c " \
touch /root/RES_install.sh_running && \
./RES_install.sh $(ls *.tar|tail -1) > /root/RES_install.sh_log && \
rm -f /root/RES_install.sh_running && \
touch /root/RES_install.sh_OK"