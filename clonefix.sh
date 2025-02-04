#!/bin/bash

echo "Stopping Geth..."
cd ~/etcmc || exit 1
./stop.sh

echo "Deleting nodekey..."
cd ~/etcmc/gethDataDirFastNode/geth || exit 1
if [ -f "nodekey" ]; then
    rm nodekey
    echo "nodekey deleted."
else
    echo "nodekey not found."
fi

echo "Deleting etcpow_balance.txt.enc..."
if [ -f "/root/etcmc/etcpow_balance.txt.enc" ]; then
    rm /root/etcmc/etcpow_balance.txt.enc
    echo "etcpow_balance.txt.enc deleted."
else
    echo "etcpow_balance.txt.enc not found."
fi

# Kontrola a mazanie backup súborov
for file in \
    /root/etcmc/etcpow_balance_backup.txt.enc.bak \
    /root/etcmc/etcpow_balance_backup.txt.enc.bak.1 \
    /root/etcmc/etcpow_balance_backup.txt.enc.bak.2 \
    /root/etcmc/etcpow_balance_backup.txt.enc.bak.3 \
    /root/etcmc/etcpow_balance_backup.txt.enc.bak.4; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "$file deleted."
    else
        echo "$file not found."
    fi
done

echo "Starting Geth..."
cd ~/etcmc || exit 1
./start.sh

echo "New nodekey generated."
