#!/bin/bash

# Script to change the icon of the application launcher with random icons from a specified folder

icon_folder_location="" # Enter the file location for your icons here

launcher_config_location="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
start_line=$(grep -n "\[Containments\]\[7\]\[Applets\]\[8\]\[Configuration\]\[General\]" "$launcher_config_location" | cut -d: -f1)

echo "Location selected:"
echo "$icon_folder_location"
echo ""

# Select two random files from the icon folder
random_file=$(ls "$icon_folder_location" | shuf -n 1)
random_file2=$(ls "$icon_folder_location" | shuf -n 1)

# Checks if the selected file is empty
if [ -z "$random_file" ]; then
    echo "No files in folder"
    exit 1
fi

# Checks if the selected file is of a supported type
case "${random_file: -4}" in
    .svg|.png|.xpm|.ico|.icns)
        echo "File $random_file selected"
        ;;
    *)
        echo "No files of supported type in folder"
        exit 1
        ;;
esac

# Check if the starting line of the desired configuration section was found
if [ -z "$start_line" ]; then
  echo "Config parameter not found... Either you are not on KDE or I did something stupid"
  exit 1
fi

icon_found=false

# Search for the line containing the "icon" parameter in the configuration section
for i in {1..40}; do
  line_num=$((start_line + i))
  line=$(sed -n "${line_num}p" "$launcher_config_location")
  
  if echo "$line" | grep -q "icon"; then
    echo "Icon found at line $line_num"
    icon_found=true
    break
  fi
done

echo ""

# If the "icon" parameter was not found, adds it.
if [ "$icon_found" = false ]; then
  line_num=$((start_line + 1))
  sed -i "${line_num}i\icon=$icon_folder_location$random_file" "$launcher_config_location"
else
  new_content="icon=$icon_folder_location$random_file"
  sed -i "${line_num}s|.*|${new_content}|" "$launcher_config_location"
fi

echo "Icon Changed! You will have to refresh plasmashell to see the effect"
echo "Refresh plasma? (Yes or No)"
read -t 15 answer

if [ -z "$answer" ] || [ "$answer" == "No" ] || [ "$answer" == "no" ]; then
  echo "Doing nothing"
elif [ "$answer" == "Yes" ] || [ "$answer" == "yes" ]; then
  echo "Restarting"
  kquitapp5 plasmashell && kstart5 plasmashell
  new_content="icon=$icon_folder_location$random_file2"
  sed -i "${line_num}s|.*|${new_content}|" "$launcher_config_location"
fi