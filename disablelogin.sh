#!/bin/bash

# Získa zoznam všetkých bežiacich LXC kontajnerov v Proxmoxe
containers=$(pct list | awk 'NR>1 {print $1}')

# Nový obsah pre login.json
new_json='{"login_required": false}'

# Prejde všetky bežiace kontajnery
echo "Updating login.json in all running LXC containers..."
for container in $containers; do
    echo "Updating container: $container"
    pct exec $container -- bash -c "cd etcmc && echo '$new_json' > login.json"
done

echo "Update complete."
