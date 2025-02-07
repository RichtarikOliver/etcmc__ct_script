#!/bin/bash

# Define the file path
FILE_PATH="/etcmc/RaewolfBot/raewolfbot.py" 

# Define the new content
NEW_CONTENT='import requests
import json
import time
import re
import os

CONFIG_FILE = "botconfig.json"
BALANCE_FILE = "/root/etcmc/write_only_etcpow_balance.txt"
CLAIM_FILE = "/root/etcmc/claim_data.txt"
LAST_CLAIM_FILE = "last_claim.txt"
API_URL = "http://165.22.90.106:5000/send_balance"
CLAIM_API_URL = "http://165.22.90.106:5000/claim_balance"

CLAIM_THRESHOLD = 100.0  # Limit pre automatické claimnutie


def load_config():
    try:
        with open(CONFIG_FILE, "r") as file:
            config = json.load(file)
            return config.get("user_id"), config.get("node_id")
    except FileNotFoundError:
        print("Error: botconfig.json doesn'\''t exist!")
        return None, None
    except json.JSONDecodeError:
        print("Error: botconfig.json doesn'\''t have valid JSON data")
        return None, None


def read_balance():
    try:
        with open(BALANCE_FILE, "r") as file:
            balance = file.readline().strip()
            return float(balance)
    except FileNotFoundError:
        print("Error: Balance file doesn'\''t exist")
    except ValueError:
        print("Error: Not valid balance")
    return None


def read_claim_data():
    """Číta ETCPOW Amount a Wallet Address zo súboru claim_data.txt."""
    try:
        with open(CLAIM_FILE, "r") as file:
            content = file.read()
            balance_match = re.search(r"ETCPOW Amount:\\s*([\\d.]+)", content)
            wallet_match = re.search(r"Wallet Address:\\s*(\\S+)", content)

            claimed_balance = float(balance_match.group(1)) if balance_match else None
            wallet_address = wallet_match.group(1) if wallet_match else None

            return claimed_balance, wallet_address
    except FileNotFoundError:
        print("Error: claim_data.txt doesn'\''t exist")
    except ValueError:
        print("Error: Invalid ETCPOW Amount value")
    return None, None


def get_file_modification_time(file_path):
    """Získanie času poslednej úpravy súboru ako timestamp."""
    try:
        mod_time = os.path.getmtime(file_path)
        return time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime(mod_time))
    except FileNotFoundError:
        return None


def read_last_claim_time():
    """Načíta posledný čas claimnutia zo súboru."""
    try:
        with open(LAST_CLAIM_FILE, "r") as file:
            return file.read().strip()
    except FileNotFoundError:
        return None


def write_last_claim_time(timestamp):
    """Zapíše posledný čas claimnutia do súboru."""
    with open(LAST_CLAIM_FILE, "w") as file:
        file.write(timestamp)


def send_claim_data():
    """Odošle informácie o claimnutom balanci a peňaženke na server iba raz."""
    user_id, node_id = load_config()
    if user_id is None or node_id is None:
        return

    claimed_balance, wallet_address = read_claim_data()
    if claimed_balance is None or wallet_address is None:
        print("Error: Could not read claimed balance or wallet address")
        return

    claim_timestamp = get_file_modification_time(CLAIM_FILE)
    if claim_timestamp is None:
        print("Error: Could not get claim file modification time")
        return

    last_claim_time = read_last_claim_time()
    if last_claim_time == claim_timestamp:
        return

    data = {
        "user_id": user_id,
        "node_id": node_id,
        "claimed_balance": claimed_balance,
        "wallet_address": wallet_address,
        "timestamp": claim_timestamp,
        "status": "none"
    }

    try:
        response = requests.post(CLAIM_API_URL, json=data, timeout=10)
        if response.status_code == 200:
            """print(f"Claim data sent successfully: {claimed_balance} at {claim_timestamp} to {wallet_address}")"""
            write_last_claim_time(claim_timestamp)
        else:
            """print(f"Error sending claim data: {response.text}")"""
    except (requests.ConnectionError, requests.Timeout):
        """print("Error: cannot access server")"""


def send_balance():
    user_id, node_id = load_config()
    if user_id is None or node_id is None:
        return

    balance = read_balance()
    if balance is None:
        return

    if balance >= CLAIM_THRESHOLD:
        send_claim_data()

    data = {
        "user_id": user_id,
        "node_id": node_id,
        "balance": balance
    }

    try:
        response = requests.post(API_URL, json=data, timeout=10)
        if response.status_code == 200:
            print(f"Balance: {balance}")
        else:
            print(f"Error: {response.text}")
    except (requests.ConnectionError, requests.Timeout):
        print("Error: cannot access server")


if __name__ == "__main__":
    while True:
        send_balance()
        time.sleep(300)
'

# Overwrite the content of the file
echo "$NEW_CONTENT" > "$FILE_PATH"

# Confirm the changes
if [[ $? -eq 0 ]]; then
    echo "✅ File '$FILE_PATH' has been successfully updated."
else
    echo "❌ Failed to update the file '$FILE_PATH'."
    exit 1
fi

# Restart the systemctl service
echo "🔄 Restarting raewolfbot.service..."
sudo systemctl restart raewolfbot.service

# Confirm the service restart
if [[ $? -eq 0 ]]; then
    echo "✅ raewolfbot.service has been successfully restarted."
else
    echo "❌ Failed to restart raewolfbot.service."
    exit 1
fi
