#!/bin/bash
cd etcmc

# Download and extract the tar file
wget https://etcmcnodecheck.apritec.dev/files-linux/etcmcnodecheck-linux-v0.10.tar
tar -xvf etcmcnodecheck-linux-v0.10.tar

# Change to the Etcmcnodecheck directory
cd Etcmcnodecheck

# Create the nodechecksetup.sh script
echo '#!/bin/bash

# Check if ID is provided as a parameter
if [ -z "$1" ]; then
  echo "You must provide an ID as a parameter, e.g., ./nodechecksetup.sh 123"
  exit 1
fi

ID=$1

# Save ID to a file
echo $ID > /root/etcmc/Etcmcnodecheck/etcmcnodemonitoringid.txt

# Install curl
sudo apt install -y curl

# Create the systemd service for node check
echo "[Unit]
Description=Etcmc Node Check Script
After=network.target

[Service]
ExecStart=/root/etcmc/Etcmcnodecheck/check-node.sh
Restart=always
User=root
WorkingDirectory=/root/etcmc/Etcmcnodecheck

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/etcmc-node-check.service

# Reload and start the systemd service
systemctl daemon-reload
systemctl enable etcmc-node-check.service
systemctl restart etcmc-node-check.service
' > nodechecksetup.sh

# Make the script executable
chmod +x nodechecksetup.sh

# Confirmation of script creation
echo "nodechecksetup.sh has been successfully created and is executable."

rm /etc/etcmcnodecheck-linux-v0.10.tar
