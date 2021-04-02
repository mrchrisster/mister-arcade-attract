#!/bin/bash

## Description
# This cycles through arcade cores periodically
# Games are randomly pulled from all MRAs or a user-provided list


## Credits
# Original concept and implementation by: mrchrisster
# Additional development by: Mellified
# And thanks to kaloun34 for contributing!
# https://github.com/mrchrisster/mister-arcade-attract/

#Default values - Recommend changing values in the INI file, not here.

mrapath="/media/fat/_Arcade"
mrapathvert="/media/fat/_Arcade/_Organized/_6 Rotation/_Vertical CW 90 Deg" 
mrapathhoriz="/media/fat/_Arcade/_Organized/_6 Rotation/_Horizontal"
mraexclude=""
timer=120
orientation=All
mralist="/media/fat/Scripts/Attract_Arcade.txt"

## Functions

parse_ini()
{
	# INI Parsing

	if [ -f ${basepath}/Attract_Arcade.ini ]; then
	basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
	. ${basepath}/Attract_Arcade.ini
	IFS=$'\n'
	fi
}

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

build_mralist()
{
	# If the file does not exist make one in /tmp/
	if [ $orientation = "All" ]; then

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
	elif [ $orientation = "Horizontal" ]; then
		
		if [ ! -f ${mralist} ]; then
			mralist="/tmp/Attract_Arcade.txt"
		
			# If no MRAs found - suicide!
			find "${mrapathhoriz}" -maxdepth 1 -type f \( -iname "*.mra" \) &>/dev/null
			if [ ! ${?} == 0 ]; then
				echo "The path ${mrapathhoriz} contains no MRA files!"
				exit 1
			fi
		
			# This prints the list of MRA files in a path,
			# Cuts the string to just the file name,
			# Then saves it to the mralist file.
			find "${mrapathhoriz}" -maxdepth 1 -type f \( -iname "*.mra" \) | cut -c $(( $(echo ${#mrapath}) + 2 ))- | grep -vFf <(printf '%s\n' ${mraexclude[@]}) > ${mralist}
		fi
	elif [ $orientation = "Vertical" ]; then
		
		if [ ! -f ${mralist} ]; then
			mralist="/tmp/Attract_Arcade.txt"
		
			# If no MRAs found - suicide!
			find "${mrapathvert}" -maxdepth 1 -type f \( -iname "*.mra" \) &>/dev/null
			if [ ! ${?} == 0 ]; then
				echo "The path ${mrapathvert} contains no MRA files!"
				exit 1
			fi
		
			# This prints the list of MRA files in a path,
			# Cuts the string to just the file name,
			# Then saves it to the mralist file.
			find "${mrapathvert}" -maxdepth 1 -type f \( -iname "*.mra" \) | cut -c $(( $(echo ${#mrapath}) + 2 ))- | grep -vFf <(printf '%s\n' ${mraexclude[@]}) > ${mralist}
		fi
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
loop_core
exit 0
