#!/bin/bash

# Step 1: Download the rar file
wget https://github.com/RichtarikOliver/etcmc__ct_script/raw/refs/heads/main/test.rar -O /root/etcmcbot.rar

# Step 2: Install unrar if not installed
if ! command -v unrar &> /dev/null
then
    echo "unrar not found, installing..."
    apt-get update
    apt-get install unrar -y
fi

# Step 3: Create the extraction folder if it doesn't exist
mkdir -p /root/node/RaewolfBot

# Step 4: Extract the rar file to /root/etcmc/RaewolfBot
unrar x /root/etcmcbot.rar /root/node/RaewolfBot/

# Step 5: Create setup.sh script
cat << 'EOF' > /root/node/RaewolfBot/setup.sh
#!/bin/bash

# Prompt for user_id and node_id
echo "Enter user_id:"
read user_id
echo "Enter node_id:"
read node_id

# Create botconfig.json with the user_id and node_id
cat << EOF2 > /root/node/RaewolfBot/botconfig.json
{
    "user_id": $user_id,
    "node_id": $node_id
}
EOF2

# Step 6: Create the system service
echo "Creating system service for the bot..."

# Create a systemd service file to start the bot at container start
cat << EOF3 > /etc/systemd/system/raewolfbot.service
[Unit]
Description=RaewolfBot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /root/node/RaewolfBot/raewolfbot.py
WorkingDirectory=/root/node/RaewolfBot
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF3

# Reload systemd to apply the new service
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable raewolfbot.service

# Start the service immediately
systemctl start raewolfbot.service

echo "Setup completed successfully! The bot is now running and will start on container boot."
EOF

# Step 6: Make setup.sh executable
chmod +x /root/node/RaewolfBot/setup.sh

# Notify the user
echo "Script setup.sh has been created successfully. You can run it manually to set up the bot."
