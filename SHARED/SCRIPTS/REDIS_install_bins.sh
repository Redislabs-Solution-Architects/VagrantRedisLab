test -f /root/RES_install.sh_running && echo 'The test -f /root/RES_install.sh_running is positive. Exit.'
test -f /root/RES_install.sh_running && exit 0

test -f /root/rl_uninstall.sh_running && echo 'The test -f /root/rl_uninstall.sh_running is positive. Wait.'
while test -f /root/rl_uninstall.sh_running; do echo "$(date) - Exists /root/rl_uninstall.sh_running. sleep 10."; echo; tail -1 /root/rl_uninstall.sh_log; echo; sleep 10; done

echo " . . Running REDIS_install_bins.sh"
cd /vagrant/PACKAGES/RES/
#./RES_install.sh $(ls *.tar|tail -1)
rm -f /root/RES_install.sh_running
rm -f /root/RES_install.sh_OK
screen -dm bash -c " \
touch /root/RES_install.sh_running && \
./RES_install.sh $(ls *.tar|tail -1) > /root/RES_install.sh_log && \
rm -f /root/RES_install.sh_running && \
touch /root/RES_install.sh_OK"