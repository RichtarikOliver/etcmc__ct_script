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

echo "Starting Geth..."
cd ~/etcmc || exit 1
./start.sh

echo "New nodekey generated."
