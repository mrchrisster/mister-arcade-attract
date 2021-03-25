# This cycles through Arcade cores listed in Attract_Arcade.txt periodically

mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
[ "${RO_ROOT}" == "true" ] && mount / -o remount,rw
cat <<\EOF > /etc/init.d/_S98attract
#!/bin/sh
trap "" HUP
trap "" TERM

sleepfpga()
{
    i=3
    while (( i > 0 )); do
    	sleep 120
    	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
    	until [ -f "/media/fat/_Arcade/${mra}" ]; do
    		mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
    	done
    	echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
    	((i++))
    done
    
    sleep 120
    mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
    until [ -f "/media/fat/_Arcade/${mra}" ]; do
    	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
   	done
    sed -i "s/.*bootcore=.*/bootcore=${mra}/" /media/fat/MiSTer.ini
    fpga /media/fat/menu.rbf

    sleepfpga &
}

start() {
				if [ -f /var/run/attract.pid ]; then
					kill -9 $(cat /var/run/attract.pid)
					rm -f /var/run/attract.pid
				fi
        printf "Starting Attract Mode: "
        sleepfpga &
        echo $!>/var/run/attract.pid
}

stop() {
        printf "Stopping Attract Mode: "
        kill -9 `attract.pid`
        rm -f /var/run/attract.pid
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
    *)
        echo "Usage: /etc/init.d/S98attract {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
EOF


mv /etc/init.d/_S98attract /etc/init.d/S98attract > /dev/null 2>&1
chmod +x /etc/init.d/S98attract
sync
[ "${RO_ROOT}" == "true" ] && mount / -o remount,ro
sync
/etc/init.d/S98attract start
    mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
		until [ -f "/media/fat/_Arcade/${mra}" ]; do
			mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
		done
    echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
