#!/bin/bash

containers=$(pct list | awk 'NR>1 {print $1}')


for ct in $containers; do
    echo "Starting update.sh in ct $ct..."
    pct exec $ct -- bash -c "cd etcmc && ./update.sh"
done

