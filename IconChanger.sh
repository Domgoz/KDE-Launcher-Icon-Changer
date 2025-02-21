#!/bin/bash

# Script to change icon of provided path with random icons

icon_folder_location="" # Enter the file location for your icons here

launcher_config_location="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
start_lines=$(grep -n "icon=" "$launcher_config_location" | cut -d: -f1)

echo "Location selected:" 
echo "$icon_folder_location"
echo ""

# Select two random files from the icon folder
random_file=$(ls "$icon_folder_location" | shuf -n 1)
random_file2=$(ls "$icon_folder_location" | shuf -n 1)


# Checks if the selected file is empty
if [ -z "$random_file" ]; then
    echo "No Files in folder"
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
if [ -z "$start_lines" ]; then
  echo "No lines containing 'icon=' found in the configuration file."
  echo "Please change the Application launcher icon once, for the "icon=" to be added."
  exit 1
fi

# Loop through each line number and edit the line
echo "$start_lines" | while IFS= read -r line_num; do
  new_content="icon=$icon_folder_location$random_file"
  sed -i "${line_num}s|.*|${new_content}|" "$launcher_config_location"
  echo "Edited line $line_num"
done

echo "Icon Changed! You will have to refresh plasmashell to see the effect"
echo "Refresh plasma? (Yes or No)"
read -t 15 answer

## Gives user a choice to either restart or not.
if [ -z "$answer" ] || [ "$answer" == "No" ] || [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
  echo "Doing nothing"
elif [ "$answer" == "Yes" ] || [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
  echo "Restarting"
  kquitapp5 plasmashell && kstart5 plasmashell
  new_content="icon=$icon_folder_location$random_file2"
  echo "$start_lines" | while IFS= read -r line_num; do
    sed -i "${line_num}s|.*|${new_content}|" "$launcher_config_location"
    echo "Edited line $line_num"
  done
fi
