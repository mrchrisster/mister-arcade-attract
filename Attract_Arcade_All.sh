#!/bin/bash

# This sets up a Linux daemon to cycle through arcade cores periodically
# Games are randomly pulled from the corresponding Attract_Arcade_All.txt
# To adjust the timeout change the "sleep" value
#
# https://github.com/mrchrisster/mister-arcade-attract/


nextcore()
{
  # Get a random game from the list
  mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_All.txt)
  # If the mra variable is valid this should immediately pass, but if not it'll keep trying
  # Partially protects against typos from manual editing and strange character parsing problems
  until [ -f "/media/fat/_Arcade/${mra}" ]; do
  	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_All.txt)
  done
  echo "${mra}"
  echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
}


case "$1" in
		next)
				# Load the next core and exit
				# For testing via ssh
				# Won't reset the timer
				nextcore
				exit 0
				;;
esac


# If another attract process is running kill it
# This can happen if the script is started multiple times
if [ -f /var/run/attract.pid ]; then
	kill -9 $(cat /var/run/attract.pid)
fi
# Save our PID
echo "$(pidof Attract_Arcade_All.sh)" > /var/run/attract.pid

# Main loop
while :; do
	nextcore
  sleep 120
done
exit 0
