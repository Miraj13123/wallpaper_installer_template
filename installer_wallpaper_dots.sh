#!/bin/bash

# === User Configuration ===
# Set the path to your wallpaper installation folder here
# Example: install_folder="$HOME/Pictures/wallpapers"
install_folder="$HOME/Pictures/wallpapers"

# Set root directory name where this script is located or stored. so that this script can be executed from one folder back from where it is stored.
# for example, this script if u cloned it from github is located in "wallpaper_installer_template" folder. so set it like this (shown bellow)
folder_name="wallpaper_installer_template"

# Set the name of the folder containing the wallpapers, relative to the script's location
# Use "." if the wallpapers are in the same directory as the script, or the folder name (e.g., "wallpapers") if they are in a subdirectory
# IMPORTANT: Use a relative path, not an absolute path, to ensure the script works if moved along with the wallpaper folder
wallpaper_folder_name="wallpapers"

# === End User Configuration ===
# You don't need to modify anything beyond this point

# Set repository root
repo_root=""
if [ -d "$folder_name" ]; then
  repo_root="./$folder_name"
else
  repo_root="."
fi

# Define the wallpaper source directory
wallpaper_dir="$repo_root/$wallpaper_folder_name"

# Define the installation directory
config_dir="$install_folder"

prompt_user() {
    while true; do
        local proceed=""
        read -p "$1 [ y/n ] : " proceed
        if [[ $proceed == "y" || $proceed == "Y" ]]; then
            return 0
        elif [[ $proceed == "n" || $proceed == "N" ]]; then
            return 1
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
}

prompt_install() {    
    echo "--------------------------------"
    echo "Welcome to my wallpapers Installer"
    echo "--------------------------------"
    if prompt_user "Do you want to Install My Wallpapers ?"; then
        echo "Installing My Wallpapers..."
        
        if [[ ! -d "$wallpaper_dir" ]]; then
            echo "Error: Source directory $wallpaper_dir does not exist."
            return 1
        fi
        
        mkdir -p "$config_dir"
        shopt -s dotglob
        cp -rfv "$wallpaper_dir/"* "$config_dir/"
        shopt -u dotglob
        
        echo "JaKooLit Wallpapers installed successfully."
        return 0
    else
        echo "Skipping JaKooLit Wallpapers installation."
        return 1
    fi
}

files_finder() {    # List files in repo directory
    local search_dir="$repo_root/$1"
    if [[ -d "$search_dir" ]]; then
        find "$search_dir" -type f 2>/dev/null
    else
        echo "Directory not found: $search_dir" >&2
        return 1
    fi
}

# Uninstall wallpapers
prompt_uninstall() {
    echo "--------------------------------"
    echo "-----Wallpaper  Uninstaller-----"
    echo "--------------------------------"
    if prompt_user "Do you want to Uninstall My Wallpapers ?"; then
        echo "Uninstalling My Wallpapers..."

        # Check if source directory exists
        if [ ! -d "$wallpaper_dir" ]; then
            echo "Error: Source directory $wallpaper_dir does not exist."
            return 1
        fi

        # Track if any files were found
        found_files=0
        
        # Loop through files in source directory
        for file in "$wallpaper_dir"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                dest_file="$config_dir/$filename"
                if [ -f "$dest_file" ]; then
                    rm -fv "$dest_file"
                    found_files=1
                fi
            fi
        done

        # Check if any files were removed
        if [ $found_files -eq 0 ]; then
            echo "No matching wallpapers found in $config_dir."
        else
            echo "Wallpapers uninstalled successfully."
        fi
        return 0
    else
        echo "Skipping Wallpapers uninstallation."
        return 1
    fi
}

menu() {
    while true; do
        echo "================================================="
        echo "=== Welcome to My Wallpaper installer ==="
        echo "================================================="
        echo "1. install My Wallpapers"
        echo "2. uninstall My Wallpapers"
        echo "[x] exit"
        echo "-------------------------------------------------"
        
        read -p "Choose an option plz: " opt
        if [[ "$opt" == "1" ]]; then
            clear
            prompt_install
        elif [[ "$opt" == "2" ]]; then
            clear
            prompt_uninstall
        elif [[ "$opt" == "x" || "$opt" == "X" ]]; then
            clear
            echo "exiting ... "
            return 0
        else
            clear
            echo "Invalid Option, please choose '1', '2', or 'x'"
        fi
    done
}

menu