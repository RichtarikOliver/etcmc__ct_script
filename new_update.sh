#!/bin/bash

# URL for file download
URL="https://github.com/Nowalski/ETCMC_Software/releases/download/Setup%2FWindows/ETCMC_Linux.zip"

# Target directory for extraction
TARGET_DIR="/root/etcmc"

# ZIP file name
ZIP_FILE="ETCMC_Linux.zip"

# Update system (voliteľné)
apt update 
apt dist-upgrade -y 

# Downloading the file
echo "Downloading the file from $URL..."
wget -O "$ZIP_FILE" "$URL"

# Checking if the file was successfully downloaded
if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: The file could not be downloaded."
    exit 1
fi

# Creating the target directory if it does not exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating the target directory $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# Extracting the ZIP file
echo "Extracting the file to $TARGET_DIR..."
python3 -m zipfile -e "$ZIP_FILE" "$TARGET_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to extract the file."
    exit 1
fi

echo "The file was successfully extracted."

# Install required dependencies
echo "Installing Python dependencies..."
apt install -y python3 python3-pip
pip3 install -r "$TARGET_DIR/requirements.txt"

# Spustenie ETCMC cez start.sh
echo "Starting ETCMC using start.sh..."
chmod +x "$TARGET_DIR/start.sh"
"$TARGET_DIR/start.sh"

echo "ETCMC update complete and started."
