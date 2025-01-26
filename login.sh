#!/bin/bash
FILE="/root/etcmc/login.json"
NEW_CONTENT='{"login_required": false}'
echo "$NEW_CONTENT" > "$FILE"
echo "Login disabled." 
