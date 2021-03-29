#!/bin/bash

# This sets up a Linux daemon to cycle through arcade cores periodically
# Games are randomly pulled from all MRAs or a user-provided list
# To adjust the timeout change the "sleep" value
#
# https://github.com/mrchrisster/mister-arcade-attract/

# Variables

# Time before going to the next core
timer=120

#Curated List of Horizontal Games

games="
Commando.mra
Gauntlet II.mra
Gauntlet (rev 14).mra
SectionZ.mra
Rampage.mra
DoDonPachi.mra
Discs of Tron.mra
Bionic Commando.mra
Black Tiger.mra
Double Dragon.mra
Forgotten Worlds -World, newer-.mra
Bubble Bobble.mra
Star Guards.mra
Daimakaimura -Japan-.mra
Double Dragon II - The Revenge.mra
F-1 Dream.mra
Forgotten Worlds -World, newer-.mra
Tetris.mra
Rush'n Attack (US).mra
Popeye.mra
Robotron 2084.mra
Dynasty Wars -USA, B-Board 89624B- -.mra
Final Fight -World, set 1-.mra
Strider -USA, B-Board 89624B-2-.mra
Tetris (cocktail set 1).mra
U.N. Squadron -USA-.mra
Willow -World-.mra
Tapper.mra
Carrier Air Wing -World 901012-.mra
Gulun.Pa_-_Prototype_1993_-_Japan_931220_L-.mra
Magic Sword Heroic Fantasy -World 900725-.mra
Mega Twins -World 900619-.mra
Nemo -World 901130-.mra
Captain Commando -World 911202-.mra
Street Fighter (US, set 1).mra
Knights of the Round -World 911127-.mra
Street Fighter II The World Warrior -World 910522-.mra
The King of Dragons -World 910805-.mra
Three Wonders -World 910520-.mra
Street Fighter II  The World Warrior -World 910522-.mra
Adventure Quiz Capcom World 2 -Japan 920611-.mra
Varth Operation Thunderstorm -World 920714-.mra
Pnickies -Japan 940608-.mra
Pokonyan! Balloon -Japan 940322-.mra
Mega Man The Power Battle -CPS1, USA 951006-.mra
Pang! 3 -Euro 950601-.mra
Quiz Tonosama no Yabou 2 Zenkoku-ban -Japan 950123-.mra
Street Fighter Zero -CPS Changer, Japan 951020-.mra
Cadillacs and Dinosaurs (World 930201).mra
Muscle Bomber Duo Ultimate Team Battle (World 931206).mra
Saturday Night Slam Masters (World 930713).mra
The Punisher (World 930422).mra
Warriors of Fate (World 921031).mra
"

# Functions

nextcore()
{
  # Get a random game from the list
  IFS=$'\n'
  mra=$(echo "${games[*]}" |shuf |head -1)
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
	ls -N1 /media/fat/_Arcade/*.mra | sed 's/\/media\/fat\/_Arcade\///' > ${mralist}
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
