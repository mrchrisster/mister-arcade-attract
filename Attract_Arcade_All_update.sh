echo "Updating /media/fat/Scripts/Attract_Arcade_All.txt"
ls -N1 /media/fat/_Arcade/*.mra | sed 's/\/media\/fat\/_Arcade\///' | tee /media/fat/Scripts/Attract_Arcade_All.txt
echo "Update complete!"
