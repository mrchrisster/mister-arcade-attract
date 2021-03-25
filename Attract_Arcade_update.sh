echo "Updating /media/fat/Scripts/Attract_Arcade.txt"
sleep 3
ls -N1 /media/fat/_Arcade/*.mra | sed 's/\/media\/fat\/_Arcade\///' | tee /media/fat/Scripts/Attract_Arcade.txt
echo "Update complete!"
