#!/bin/bash

# This loads a random arcade core from all MRAs
#
# https://github.com/mrchrisster/mister-arcade-attract/


# Dump a list of all MRAs
mralist="/tmp/Attract_Arcade.txt"
ls -N1 /media/fat/_Arcade/*.mra | sed 's/\/media\/fat\/_Arcade\///' > ${mralist}

# Greeting
clear
echo "So you're feeling lucky?"
echo ""

# Get a random game from the list
mra=$(shuf -n 1 ${mralist})
# If the mra variable is valid this should immediately pass, but if not it'll keep trying
# Partially protects against typos from manual editing and strange character parsing problems
until [ -f "/media/fat/_Arcade/${mra}" ]; do
	mra=$(shuf -n 1 ${mralist})
done

# Strip the extension for display purposes
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
