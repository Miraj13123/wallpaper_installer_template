#!/bin/bash

# === User Configuration ===
# Set the path to your wallpaper installation folder here
# Example: install_folder="$HOME/Pictures/wallpapers"
install_folder="$HOME/Pictures/wallpapers"
#now it is set to the default hyprland wallpaper location

# Set root directory name where this script is located or stored. so that this script can be executed from one folder back from where it is stored.
# for example, this script if u cloned it from github is located in "wallpaper_installer_template" folder. so set it like this (shown bellow)
folder_name="wallpaper_installer_template"

# === End User Configuration ===
# you dont need to touch beyon that

repo_root=""
if [ -d "$folder_name" ]; then
  repo_root="./$folder_name"
else
  repo_root="."
fi

# Define temp directory
anvil="$repo_root/temp"

# Ensure temp and install folders exist
mkdir -p "$anvil" "$install_folder"

# Function to display folder options
options_show() {
  local options=("$repo_root"/*/)
  local num=1
  for dir in "${options[@]}"; do
    # Extract only the folder name
    dir_name=$(basename "$dir")
    echo "$num. $dir_name"
    ((num++))
  done
}

# Function to get folder choice
options_chooser() {
  local choice=$1
  local options=("$repo_root"/*/)
  local selected_dirs=()

  if [[ "$choice" == "all" ]]; then
    for dir in "${options[@]}"; do
      selected_dirs+=("$dir")
    done
  else
    local num=1
    for dir in "${options[@]}"; do
      if [[ $num -eq $choice ]]; then
        selected_dirs+=("$dir")
        break
      fi
      ((num++))
    done
  fi
  echo "${selected_dirs[@]}"
}

# Function to copy wallpapers to temp folder
copy_to_temp() {
  local dirs=("$@")

  # Clear temp folder before copying
  rm -rfv "$anvil"/*
  mkdir -p "$anvil"

  # Copy all image files (png, jpg, jpeg, gif)
  for dir in "${dirs[@]}"; do
    find "$dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" \) -exec cp {} "$anvil" \;
  done
  echo "All wallpapers (png, jpg, jpeg, gif) copied to $anvil"
}

# Function to copy wallpapers from temp to install folder
copy_to_install() {
  if [ -z "$(ls -A "$anvil")" ]; then
    echo "Temp folder is empty. Please run temporary install first."
    return 1
  fi

  cp -rv "$anvil"/* "$install_folder"/
  echo "Wallpapers copied to $install_folder"
}

# Function to clear temp folder
clear_temp() {
  rm -rfv "$anvil"/*
  echo "Temp folder cleared."
}

# Function to delete matching files from install folder based on temp
delete_matching_from_install() {
  if [ -z "$(ls -A "$anvil")" ]; then
    echo "Temp folder is empty. Nothing to uninstall."
    return 1
  fi

  local found_files=0
  for file in "$anvil"/*; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      dest_file="$install_folder/$filename"
      if [ -f "$dest_file" ]; then
        rm -fv "$dest_file"
        found_files=1
      fi
    fi
  done

  if [ $found_files -eq 0 ]; then
    echo "No matching wallpapers found in $install_folder."
  else
    echo "Matching wallpapers uninstalled successfully."
  fi
}

# Main menu
menu() {
  while true; do
    echo "================================"
    echo "===== Wallpaper Manager ====="
    echo "================================"
    echo "[1 /      load] Temporary install (copy to temp folder)"
    echo "[2 /    unload] Clear temp folder"
    echo "[3 /   install] Install permanently (copy from temp to wallpapers)"
    echo "[4 / uninstall] Uninstall matching wallpapers (delete from wallpapers matching temp)"
    echo "[x /      exit] Exit"
    echo ""

    read -p "Choose an option (1-4, x): " main_choice

    if [[ "$main_choice" == "1" || "$main_choice" == "load" ]]; then
        clear
        # Temporary install
        echo ""
        echo "Available folders:"
        options_show
        echo ""
        read -p "Choose folder number or 'all': " folder_choice

        # Get selected directories
        IFS=' ' read -r -a selected_dirs <<< "$(options_chooser "$folder_choice")"

        if [ ${#selected_dirs[@]} -eq 0 ]; then
          echo "Invalid choice. Please try again."
          continue
        fi

        # Copy all image files to temp
        copy_to_temp "${selected_dirs[@]}"
    elif [[ "$main_choice" == "2" || "$main_choice" == "unload" ]]; then
        clear
        # Clear temp folder
        clear_temp
    elif [[ "$main_choice" == "3" || "$main_choice" == "install" ]]; then
        clear
        # Permanent install
        copy_to_install
    elif [[ "$main_choice" == "4" || "$main_choice" == "uninstall" ]]; then
        clear
        # Uninstall matching wallpapers
        delete_matching_from_install
    elif [[ "$main_choice" == "x" || "$main_choice" == "exit" ]]; then
        # Exit
        echo "Exiting..."
        break
    else
        echo " X x Invalid Choice !! x X\n ===> Please choose a number or keyword shown in the menu!"
    fi
  done
}

# Run the menu
menu