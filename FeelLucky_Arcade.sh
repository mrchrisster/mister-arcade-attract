#!/bin/bash

## Description
# This loads a random arcade core from all MRAs
# Then displays the result before loading it


## Credits
# Original concept and implementation by: mrchrisster
# Additional development by: Mellified
# And thanks to kaloun34 for contributing!
# https://github.com/mrchrisster/mister-arcade-attract/


## Variables
# Edit here or save preferred values in
# /media/fat/Scripts/Arcade_Attract.ini
# Example:
# mrapath=/media/usb0/_Arcade

# Vertical files to use
mravert="_Vertical CW 90 Deg"
# Directory for _Arcade files - no trailing slash!
mrapath="/media/fat/_Arcade"
#mrapath="/media/fat/_Arcade/_Organized/_6 Rotation/_Horizontal"
#mrapath="/media/fat/_Arcade/_Organized/_6 Rotation/${mravert}"
# Time before going to the next core
timer=120
# List of MRAs
mralist="/media/fat/Scripts/Attract_Arcade.txt"
# Excluded MRAs
declare -a mraexclude=('Example Bad.mra' 'Fake Example.mra')


## Functions
parse_cmdline()
{
	# Load the next core and exit - for testing via ssh
	# Won't reset the timer!
	case "${1}" in
			next)
					next_core
					exit 0
					;;
	esac
}

there_can_be_only_one()
{
	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	if [ -f /var/run/attract.pid ]; then
		kill -9 $(cat /var/run/attract.pid) &>/dev/null
	fi
	# Save our PID
	echo "$(pidof $(basename ${1}))" > /var/run/attract.pid
}

parse_ini()
{
	# INI Parsing - be kind
	if [ -f /media/fat/Scripts/Attract_Arcade.ini ]; then
		while IFS='= ' read var val; do
			if [[ ${val} ]]; then
	      declare -g "${var}=${val}"
	    fi
		done < /media/fat/Scripts/Attract_Arcade.ini
	fi
}

build_mralist()
{
	# If the file does not exist make one in /tmp/
	if [ ! -f ${mralist} ]; then
		mralist="/tmp/Attract_Arcade.txt"
		
		# If no MRAs found - suicide!
		find "${mrapath}" -maxdepth 1 -type f \( -iname "*.mra" \) &>/dev/null
		if [ ! ${?} == 0 ]; then
			echo "The path ${mrapath} contains no MRA files!"
			exit 1
		fi
		
		# This prints the list of MRA files in a path,
		# Cuts the string to just the file name,
		# Then saves it to the mralist file.
		find "${mrapath}" -maxdepth 1 -type f \( -iname "*.mra" \) | cut -c $(( $(echo ${#mrapath}) + 2 ))- | grep -vFf <(printf '%s\n' ${mraexclude[@]}) > ${mralist}
	fi
}

next_core()
{
	# Get a random game from the list
	mra=$(shuf -n 1 ${mralist})

	# If the mra variable is valid this is skipped, but if not it'll try 10 times
	# Partially protects against typos from manual editing and strange character parsing problems
	for i in {1..10}; do
		if [ ! -f "${mrapath}/${mra}" ]; then
			mra=$(shuf -n 1 ${mralist})
		fi
	done
	# If the MRA is still not valid something is wrong - suicide
	if [ ! -f "${mrapath}/${mra}" ]; then
		exit 1
	fi

	echo "You'll be playing:"
	# Bold the MRA name - remove trailing .mra
	echo -e "\e[1m $(echo $(basename "${mra}") | sed -e 's/\.[^.]*$//')"
	# Reset text
	echo -e "\e[0m"

	if [ "${1}" == "quarters" ]; then
		echo "Loading quarters in..."
		for i in {5..1}; do
			echo "${i} seconds"
			sleep 1
		done
	fi

  # Tell MiSTer to load the next MRA
  echo "load_core ${mrapath}/${mra}" > /dev/MiSTer_cmd
}

loop_core()
{
	while :; do
		next_core
  	sleep ${timer}
	done
}

get_lucky()
{
	echo "So you're feeling lucky?"
	echo ""
	
	next_core quarters
}


## Prep
parse_ini
build_mralist
parse_cmdline ${1}
there_can_be_only_one ${0}


## Main
get_lucky
exit 0
