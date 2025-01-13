#!/bin/bash

# URL for file download
URL="https://github.com/Nowalski/ETCMC_Software/releases/download/Setup%2FWindows/ETCMC_Linux.zip"

# Path for the service file
SERVICE_FILE="/etc/systemd/system/etcmc.service"

# Target directory for extraction
TARGET_DIR="/root/etcmc"

# ZIP file name
ZIP_FILE="ETCMC_Linux.zip"

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

# Extracting the ZIP file without using unzip
echo "Extracting the file to $TARGET_DIR..."
python3 -m zipfile -e "$ZIP_FILE" "$TARGET_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to extract the file."
    exit 1
fi

echo "The file was successfully extracted."

# Running the installation script
echo "Running the installation script..."
cd "$TARGET_DIR"
# chmod +x install_script.sh
# sed -i 's/\r$//' install_script.sh
# ./install_script.sh
apt install python3 python3-pip screen curl jq  -y 
pip3 install -r requirements.txt
chmod +x Linux.py ETCMC_GETH.py updater.py geth

sudo apt update


# Creating update.sh
echo "Creating update.sh..."
cat > "$TARGET_DIR/update.sh" <<EOL
#!/bin/bash
python3 Linux.py stop
python3 Linux.py update
pip3 install -r requirements.txt
echo 'ETCMC Updated. Starting ETCMC Node now...'
sleep 5
./start.sh
EOL
chmod +x "$TARGET_DIR/update.sh"

# Creating start.sh
echo "Creating start.sh..."
cat > "$TARGET_DIR/start.sh" <<EOL
#!/bin/bash
# Starting ETCMC in a screen session
/usr/bin/screen -dmS etcmc /usr/bin/python3 $TARGET_DIR/Linux.py start --port 5000
EOL
chmod +x "$TARGET_DIR/start.sh"

# Creating stop.sh
echo "Creating stop.sh..."
cat > "$TARGET_DIR/stop.sh" <<EOL
#!/bin/bash
# Stopping ETCMC
/usr/bin/python3 $TARGET_DIR/Linux.py stop
EOL
chmod +x "$TARGET_DIR/stop.sh"

# Creating poweroff.sh
echo "Creating poweroff.sh..."
cat > "$TARGET_DIR/poweroff.sh" <<EOL
#!/bin/bash
# Stopping ETCMC and powering off the device
$TARGET_DIR/stop.sh
/sbin/poweroff
EOL
chmod +x "$TARGET_DIR/poweroff.sh"

# Creating the systemd service
echo "Creating the systemd service..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=ETCMC
After=network.target

[Service]
User=root
Group=root
ExecStartPre=/bin/sleep 20
ExecStart=$TARGET_DIR/start.sh
WorkingDirectory=$TARGET_DIR
StandardOutput=append:/var/log/etcmcscript.log
StandardError=append:/var/log/etcmcscript.log
Environment=PATH=/usr/local/bin:/usr/bin:/bin
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOL

# Reloading systemd services
echo "Reloading the systemd services..."
sudo systemctl daemon-reload
sudo systemctl enable etcmc.service
sudo systemctl start etcmc.service

clear

# Retrieving the current IP address
echo "The current IP address of the device:"
hostname -I | awk '{print $1}'

# Waiting 5 seconds before rebooting
echo "Waiting 5 seconds before rebooting..."
sleep 5

# Rebooting the system
echo "Rebooting the system..."
sudo reboot

echo "Installation completed."
