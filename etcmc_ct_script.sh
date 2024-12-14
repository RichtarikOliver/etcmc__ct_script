#!/bin/bash

# URL na stiahnutie súboru
URL="https://github.com/Nowalski/ETCMC_Software/releases/download/Setup%2FWindows/ETCMC_Linux.zip"

# Nastavenie cesty pre služobný súbor
SERVICE_FILE="/etc/systemd/system/etcmc.service"

# Cieľová zložka pre extrakciu
TARGET_DIR="/root/etcmc"

# Názov ZIP súboru
ZIP_FILE="ETCMC_Linux.zip"

# Stiahnutie súboru
echo "Sťahovanie súboru z $URL..."
wget -O "$ZIP_FILE" "$URL"

# Kontrola, či sa súbor úspešne stiahol
if [ ! -f "$ZIP_FILE" ]; then
    echo "Chyba: Súbor sa nepodarilo stiahnuť."
    exit 1
fi

# Vytvorenie cieľovej zložky, ak neexistuje
if [ ! -d "$TARGET_DIR" ]; then
    echo "Vytváranie cieľovej zložky $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
fi

# Extrahovanie ZIP súboru bez použitia unzip
echo "Extrahovanie súboru do $TARGET_DIR..."
python3 -m zipfile -e "$ZIP_FILE" "$TARGET_DIR"

if [ $? -ne 0 ]; then
    echo "Chyba: Nepodarilo sa extrahovať súbor."
    exit 1
fi

echo "Súbor bol úspešne extrahovaný."

# Spustenie inštalačného skriptu
echo "Spúšťanie inštalačného skriptu..."
cd "$TARGET_DIR"
chmod +x install_script.sh
sed -i 's/\r$//' install_script.sh
./install_script.sh

sudo apt update
sudo apt install screen -y

# Vytvorenie update.sh
echo "Vytváram update.sh..."
cat > "$TARGET_DIR/update.sh" <<EOL
#!/bin/bash
python3 Linux.py stop
python3 Linux.py update
echo 'ETCMC Updated. Starting ETCMC Node now...'
sleep 5
./start.sh
EOL
chmod +x "$TARGET_DIR/update.sh"

# Vytvorenie start.sh
echo "Vytváram start.sh..."
cat > "$TARGET_DIR/start.sh" <<EOL
#!/bin/bash
# Spustenie ETCMC v screen relácii
/usr/bin/screen -dmS etcmc /usr/bin/python3 $TARGET_DIR/Linux.py start --port 5000
EOL
chmod +x "$TARGET_DIR/start.sh"

# Vytvorenie stop.sh
echo "Vytváram stop.sh..."
cat > "$TARGET_DIR/stop.sh" <<EOL
#!/bin/bash
# Zastavenie ETCMC
/usr/bin/python3 $TARGET_DIR/Linux.py stop
EOL
chmod +x "$TARGET_DIR/stop.sh"

# Vytvorenie poweroff.sh
echo "Vytváram poweroff.sh..."
cat > "$TARGET_DIR/poweroff.sh" <<EOL
#!/bin/bash
# Zastavenie ETCMC a vypnutie zariadenia
$TARGET_DIR/stop.sh
/sbin/poweroff
EOL
chmod +x "$TARGET_DIR/poweroff.sh"

# Vytvorenie systemd služby
echo "Vytváram systemd službu..."
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

# Načítanie novej služby do systemd
echo "Načítanie služby..."
sudo systemctl daemon-reload
sudo systemctl enable etcmc.service
sudo systemctl start etcmc.service

# Zobrazenie stavu služby
echo "Kontrola stavu služby:"
sudo systemctl status etcmc.service

# Získanie aktuálnej IP adresy
echo "Aktuálna IP adresa zariadenia:"
hostname -I | awk '{print $1}'

# Počkanie 5 sekúnd pred reštartom
echo "Čakám 5 sekúnd pred reštartom..."
sleep 5

# Reštart systému
echo "Reštartujem systém..."
sudo reboot

echo "Inštalácia dokončená."
