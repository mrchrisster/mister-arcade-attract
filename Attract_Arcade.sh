#!/bin/bash

# This sets up a Linux daemon to cycle through arcade cores periodically
# Games are randomly pulled from all MRAs or a user-provided list
# To adjust the timeout change the "sleep" value
#
# https://github.com/mrchrisster/mister-arcade-attract/

# Variables

# Time before going to the next core
timer=120


# Functions

nextcore()
{
  # Get a random game from the list
  mra=$(shuf -n 1 ${mralist})
  # If the mra variable is valid this should immediately pass, but if not it'll keep trying
  # Partially protects against typos from manual editing and strange character parsing problems
  until [ -f "/media/fat/_Arcade/${mra}" ]; do
  	mra=$(shuf -n 1 ${mralist})
  done
  
  # Debug output - connect and run script via SSH
  echo "${mra}"

  # Tell MiSTer to load the next MRA
  echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
}


# Script Start

# Get our list of MRAs from the Scripts file
mralist="/media/fat/Scripts/Attract_Arcade.txt"

# If the file does not exist make one in /tmp/
if [ ! -f /media/fat/Scripts/Attract_Arcade.txt ]; then
	mralist="/tmp/Attract_Arcade.txt"
	find /media/fat/_Arcade -type f \( -iname "*.mra" \) | sed 's/\/media\/fat\/_Arcade\///' > ${mralist}
fi

# Load the next core and exit - for testing via ssh
# Won't reset the timer!
case "$1" in
		next)
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
echo "$(pidof ${0})" > /var/run/attract.pid


# Loop
while :; do
	nextcore
  sleep ${timer}
done
exit 0
