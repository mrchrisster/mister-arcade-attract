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
echo "Reboot the MiSTer"
echo ""
echo "Starting in..."
for i in {5..1}; do
	echo "${i} seconds"
	sleep 1
done


nextcore()
{
  # Get a random game from the list
  mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_Horiz.txt)
  # If the mra variable is valid this should immediately pass, but if not it'll keep trying
  # Partially protects against typos from manual editing and strange character parsing problems
  until [ -f "/media/fat/_Arcade/${mra}" ]; do
  	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade_Horiz.txt)
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

sleepfpga
