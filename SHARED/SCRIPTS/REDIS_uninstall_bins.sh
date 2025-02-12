test -f /root/rl_uninstall.sh_running && echo 'The test -f /root/rl_uninstall.sh_running is positive. Exit.'
test -f /root/rl_uninstall.sh_running && exit 0
test -f /root/RES_install.sh_running && echo 'The test -f /root/RES_install.sh_running is positive. Exit.'
test -f /root/RES_install.sh_running && exit 0
echo " . . Testing rl_uninstall.sh exists"
which rl_uninstall.sh || echo " . . WARNING: rl_uninstall.sh does not exists"
which rl_uninstall.sh || exit 0
#$(which rl_uninstall.sh)
rm -f /root/rl_uninstall.sh_OK
rm -f /root/rl_uninstall.sh_running
screen -dm bash -c " \
touch /root/rl_uninstall.sh_running && \
$(which rl_uninstall.sh) > /root/rl_uninstall.sh_log && \
rm -f /root/rl_uninstall.sh_running && \
touch /root/rl_uninstall.sh_OK"