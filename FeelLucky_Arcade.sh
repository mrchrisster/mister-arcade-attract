#!/bin/bash

# This loads a random arcade core from Attract_Arcade.txt
#
# https://github.com/mrchrisster/mister-arcade-attract/


echo "So you're feeling lucky?"
echo ""
# Get a random game from the list
mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
# If the mra variable is valid this should immediately pass, but if not it'll keep trying
# Partially protects against typos from manual editing and strange character parsing problems
until [ -f "/media/fat/_Arcade/${mra}" ]; do
	mra=$(shuf -n 1 /media/fat/Scripts/Attract_Arcade.txt)
done
# Strip the extension
mra_short=$(echo "${mra}" | sed -e 's/\.[^.]*$//')

echo "You'll be playing:"
# Bold the MRA name
echo -e "\e[1m ${mra_short}"
# Reset text
echo -e "\e[0m"

echo "Loading quarters in..."
for i in {5..1}; do
	echo "${i} seconds"
	sleep 1
done

echo "load_core /media/fat/_Arcade/${mra}" > /dev/MiSTer_cmd
