# Mister Arcade Attract Mode
This script starts a random Arcade game from your collection every 2 minutes on your MiSTer FPGA device. You can play the game during that time, but it will automatically switch to a new game after 2 mins. When you're done, perform a *cold reboot* of your MiSTer from the OSD (F12) menu - or use the power button!

# Usage
To cycle through all MiSTer Arcade cores, copy Attract_Arcade.sh and Attract_Arcade.ini to /media/fat/Scripts Directory.
Attract_Arcade.ini is optional but recommended for more customization options.

## Custom List
To use a custom list of arcade games to play create /media/fat/Scripts/Attract_Arcade.txt with 1 MRA file - including extension - per line.

## Horizontal or Vertical Only
For a list of only horizontal or vertical Arcade Games, change the "orientation" setting in the Attract_Arcade.ini file

## Exclude
If you want to exclude certain games, add the games to mraexclude in the Attract_Arcade.ini file

Make sure you have your Arcade roms setup correctly. [Update-all](https://github.com/theypsilon/Update_All_MiSTer) script works great for that.

# Feeling Lucky?
Included is FeelLucky_Arcade.sh, which is a fun way to explore your MiSTer arcade library. The script loads a single random arcade game. Play and enjoy!
