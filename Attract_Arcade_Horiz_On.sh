#!/bin/bash

# This sets up a Linux daemon to cycle through arcade cores periodically
# Games are randomly pulled from Attract_Arcade.txt
# To adjust the timeout change the "sleep" value
#
# https://github.com/mrchrisster/mister-arcade-attract/


# Intro
echo "Welcome to Attract mode for MiSTer arcade games!"
echo ""
echo "To disable:"
echo "1. Open the OSD (F12) and go right"
echo "2. Select reboot"
echo "3. Open the OSD again and open the Scripts menu"
echo "4. Select attract_arcade_off"
echo ""
echo "Starting in..."
for i in {5..1}; do
	echo "${i} seconds"
	sleep 1
done


# Create the daemon script on disk
mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
[ "${RO_ROOT}" == "true" ] && mount / -o remount,rw
cat <<\EOF > /etc/init.d/_S98attract
#!/bin/sh
trap "" HUP
trap "" TERM

nextcore()
{
  # Get a random game from the list
  mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_Horizontal.txt)
  # If the mra variable is valid this should immediately pass, but if not it'll keep trying
  # Partially protects against typos from manual editing and strange character parsing problems
  until [ -f "/media/fat/_Arcade/${mra}" ]; do
  	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_Horizontal.txt)
  done
  echo "${mra}"
  echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
}

sleepfpga()
{
  while :; do
		nextcore
    sleep 120
  done
}

start() {
	# If another attract process is running kill it
	# This can happen if the MiSTer is rebooted manually
	if [ -f /var/run/attract.pid ]; then
		kill -9 $(cat /var/run/attract.pid)
	fi
  printf "Starting Attract Mode: "
  sleepfpga &
  echo $!>/var/run/attract.pid
}

stop() {
  printf "Stopping Attract Mode: "
	if [ -f /var/run/attract.pid ]; then
		kill -9 $(cat /var/run/attract.pid)
    rm -f /var/run/attract.pid
	fi
  echo "OK"
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
		next)
				nextcore
				;;
    *)
        echo "Usage: /etc/init.d/S98attract {start|stop|restart|next}"
        echo "Note: next will load the next core immediately but does not reset the timer!"
        exit 1
        ;;
esac

exit 0
EOF


# Install the daemon
mv /etc/init.d/_S98attract /etc/init.d/S98attract > /dev/null 2>&1
chmod +x /etc/init.d/S98attract
sync
[ "${RO_ROOT}" == "true" ] && mount / -o remount,ro
sync


# Run the daemon
/etc/init.d/S98attract start
