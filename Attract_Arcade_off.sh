mount | grep -q "on / .*[(,]ro[,$]" && RO_ROOT="true"
[ "${RO_ROOT}" == "true" ] && mount / -o remount,rw
mv /etc/init.d/S98attract /etc/init.d/_S98attract > /dev/null 2>&1
sync
[ "${RO_ROOT}" == "true" ] && mount / -o remount,ro
sed -i "s/.*bootcore=.*/#bootcore=/" /media/fat/MiSTer.ini

echo "Attract mode is off and"
echo "inactive at startup."
echo "Done!"
echo "Rebooting in 5s"
sync
sleep 5 && fpga /media/fat/menu.rbf
exit 0
