#This cycles through Arcade cores every 5 mins 

mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
cat <<\EOF > /etc/init.d/_S98attract
#!/bin/sh
trap "" HUP
trap "" TERM
sleepfpga()
{
    sleep 300
    mra=$(shuf -n 1 /media/fat/Scripts/mra.txt)
    echo "load_core /media/fat/_Arcade/$mra" > /dev/MiSTer_cmd
}
start() {
        printf "Starting Attract Mode: "
        sleepfpga &
        echo $!>/var/run/attract.pid
}
stop() {
        printf "Stopping Attract Mode: "
        kill -9 `attract.pid`
        rm /var/run/attract.pid
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
[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
sync
/etc/init.d/S98attract start
    mra=$(shuf -n 1 /media/fat/Scripts/mra.txt)
    echo "load_core /media/fat/_Arcade/$mra" > /dev/MiSTer_cmd
