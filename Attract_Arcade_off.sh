#!/bin/bash

killall -q -9 S98attract
rm -f /var/run/attract.pid

# Verify the daemon exists
if [ ! -f /etc/init.d/S98attract ]; then
	echo "Attract mode is not present!"
	exit 0
fi

# Disable the daemon
mount | grep -q "on / .*[(,]ro[,$]" && RO_ROOT="true"
[ "${RO_ROOT}" == "true" ] && mount / -o remount,rw
mv /etc/init.d/S98attract /etc/init.d/_S98attract > /dev/null 2>&1
sync
[ "${RO_ROOT}" == "true" ] && mount / -o remount,ro

# Legacy - remove bootcore
#sed -i "s/.*bootcore=.*/#bootcore=/" /media/fat/MiSTer.ini

# Reboot
echo "Attract mode is off and"
echo "inactive at startup."
echo ""
echo "Rebooting in..."
sync
for i in {5..1}; do
	echo "${i} seconds"
	sleep 1
done

echo "load_core /media/fat/menu.rbf" > /dev/MiSTer_cmd

exit 0
