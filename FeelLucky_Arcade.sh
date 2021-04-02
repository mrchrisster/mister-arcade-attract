#!/bin/bash

## Description
# This loads a random arcade game
# Games are randomly pulled from all MRAs or a user-provided list


## Credits
# Original concept and implementation by: mrchrisster
# Additional development by: Mellified
# And thanks to kaloun34 for contributing!
# https://github.com/mrchrisster/mister-arcade-attract/

#Default values - Recommend changing values in the INI file, not here.
mrapath="/media/fat/_Arcade/"
mrapathvert="/media/fat/_Arcade/_Organized/_6 Rotation/_Vertical CW 90 Deg/"
mrapathhoriz="/media/fat/_Arcade/_Organized/_6 Rotation/_Horizontal/"
declare -a mraexclude
timer=120
orientation=All
mralist="/media/fat/Scripts/Attract_Arcade.txt"
debugmain=false
debugfunc=false
tracemain=false
tracefunc=false
traceparse_ini=false
tracebuild_mralist=false
tracenext_core=false


## Functions

parse_ini()
{
	if ${debugfunc}; then echo "Inside parse_ini"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	# INI Parsing
	basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
	if [ -f ${basepath}/Attract_Arcade.ini ]; then
		. ${basepath}/Attract_Arcade.ini
		IFS=$'\n'
	fi

	# Remove trailing slash from paths
	for var in mrapath mrapathvert mrapathhoriz; do
		if ${traceparse_ini}; then echo "var=${var} | \${!var}=${!var} | \${!var%/}=${!var%/}"; fi
		declare -g ${var}="${!var%/}"
		if ${traceparse_ini}; then echo "${var}=${!var}"; fi
	done

	# Set mrapath based on orientation
	if ${traceparse_ini}; then echo "mrapath=${mrapath}"; fi
	if [ "${orientation}" == "Vertical" ]; then
		mrapath="${mrapathvert}"
	elif [ "${orientation}" == "Horizontal" ]; then
		mrapath="${mrapathhoriz}"
	fi
	if ${traceparse_ini}; then echo "mrapath=${mrapath}"; fi
	
	if ${debugfunc}; then echo "Leaving parse_ini"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

parse_cmdline()
{
	if ${debugfunc}; then echo "Entered parse_cmdline"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	# Load the next core and exit - for testing via ssh
	# Won't reset the timer!
	case "${1}" in
			next)
					next_core
					exit 0
					;;
	esac
	
	if ${debugfunc}; then echo "Leaving parse_cmdline"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

there_can_be_only_one()
{
	if ${debugfunc}; then echo "Entered there_can_be_only_one"; fi
	if ${tracefunc}; then	echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	if [ -f /var/run/attract.pid ]; then
		kill -9 $(cat /var/run/attract.pid) &>/dev/null
	fi
	# Save our PID
	echo "$(pidof $(basename ${1}))" > /var/run/attract.pid
	
	if ${debugfunc}; then echo "Leaving there_can_be_only_one"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

build_mralist()
{
	if ${debugfunc}; then echo "Entered build_mralist"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	# If the file does not exist make one in /tmp/
	if [ ! -f ${mralist} ]; then
		mralist="/tmp/Attract_Arcade.txt"
	fi
	
	# If no MRAs found - suicide!
	find "${mrapath}" -maxdepth 1 -type f \( -iname "*.mra" \) &>/dev/null
	if [ ! ${?} == 0 ]; then
		echo "The path ${mrapath} contains no MRA files!"
		exit 1
	fi
	
	# This prints the list of MRA files in a path,
	# Cuts the string to just the file name,
	# Then saves it to the mralist file.
	
	# If there is an empty exclude list ignore it
	# Otherwise use it to filter the list
	if [ ${#mraexclude[@]} -eq 0 ]; then
		find "${mrapath}" -maxdepth 1 -type f \( -iname "*.mra" \) | cut -c $(( $(echo ${#mrapath}) + 2 ))- >"${mralist}"
	else
		find "${mrapath}" -maxdepth 1 -type f \( -iname "*.mra" \) | cut -c $(( $(echo ${#mrapath}) + 2 ))- | grep -vFf <(printf '%s\n' ${mraexclude[@]})>"${mralist}"
	fi
	
	if ${debugfunc}; then echo "Leaving build_mralist"; fi
	if ${tracefunc}; then	echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

next_core()
{
	if ${debugfunc}; then echo "Entered next_core"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
	if ${tracenext_core}; then echo "Seeding \$mra from mralist=${mralist}"; fi

	# Get a random game from the list
	mra="$(shuf -n 1 ${mralist})"

	if ${tracenext_core}; then echo "mra=${mra}"; fi

	# If the mra variable is valid this is skipped, but if not it'll try 10 times
	# Partially protects against typos from manual editing and strange character parsing problems
	for i in {1..10}; do
		if [ ! -f "${mrapath}/${mra}" ]; then
			mra=$(shuf -n 1 ${mralist})
			if ${tracenext_core}; then echo "mra=${mra}"; fi
		fi
	done
	# If the MRA is still not valid something is wrong - suicide
	if [ ! -f "${mrapath}/${mra}" ]; then
		echo "There is no valid file at ${mrapath}/${mra}!"
		exit 1
	fi

	echo "You'll be playing:"
	# Bold the MRA name - remove trailing .mra
	echo -e "\e[1m $(echo $(basename "${mra}") | sed -e 's/\.[^.]*$//') \e[0m"

	if ${tracenext_core}; then echo "cmdline=${1}"; fi
	if [ "${1}" == "quarters" ]; then
		echo "Loading quarters in..."
		for i in {5..1}; do
			echo "${i} seconds"
			sleep 1
		done
	fi

	if ${tracenext_core}; then echo "command is load_core ${mrapath}/${mra}"; fi
  # Tell MiSTer to load the next MRA
  echo "load_core ${mrapath}/${mra}" > /dev/MiSTer_cmd
  
  if ${debugfunc}; then echo "Leaving next_core"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

loop_core()
{
	if ${debugfunc}; then echo "Entered loop_core"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	while :; do
		next_core
  	sleep ${timer}
	done
	
	if ${debugfunc}; then echo "Leaving loop_core"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}

get_lucky()
{
	if ${debugfunc}; then echo "Entered get_lucky"; fi
	if ${tracefunc}; then	echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

	echo "So you're feeling lucky?"
	echo ""
	
	next_core quarters
	
	if ${debugfunc}; then echo "Leaving get_lucky"; fi
	if ${tracefunc}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
}


## Prep
if ${debugmain}; then echo -e "\e[1mEntering parse_ini\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
parse_ini
if ${debugmain}; then echo -e "\e[1mLeft parse_ini\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

if ${debugmain}; then	echo -e "\e[1mEntering build_mralist\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
build_mralist
if ${debugmain}; then echo -e "\e[1mLeft build_mralist\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

if ${debugmain}; then	echo -e "\e[1mEntering parse_cmdline\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
parse_cmdline ${1}
if ${debugmain}; then echo -e "\e[1mLeft parse_cmdline\e[0m"; fi
if ${tracemain}; then	echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

if ${debugmain}; then echo -e "\e[1mEntering there_can_be_only_one\e[0m"; fi
if ${tracemain}; then	echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
there_can_be_only_one ${0}
if ${debugmain}; then echo -e "\e[1mLeft there_can_be_only_one\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi


## Main
if ${debugmain}; then echo -e "\e[1mEntering get_lucky\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi
get_lucky
if ${debugmain}; then echo -e "\e[1mLeft get_lucky\e[0m"; fi
if ${tracemain}; then echo "mrapath=${mrapath} | mrapathvert=${mrapathvert} | mrapathhoriz=${mrapathhoriz} | mraexclude=${mrapathexclude} | timer=${timer} | orientation=${orientation} | mralist=${mralist}"; fi

exit 0
