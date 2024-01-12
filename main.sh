#!/bin/bash

# Get the start time of the setup in seconds
startTime=$(date +%s)
endTime=$(date +%s)
elapsed=$((endTime-startTime))
echo "startup script took: $elapsed seconds"

cat packages_version.txt


sleep inf &
wait
