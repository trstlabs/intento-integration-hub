#!/bin/bash
ENDPOINT="https://lcd.osmosis.zone"
# URL of the API endpoint
URL=$ENDPOINT"/osmosis/gamm/v1beta1/pools"

# Output file where the response will be saved
OUTPUT_FILE="osmosis_pools.json"

# Use curl to fetch the data and save it to the output file
curl -s "$URL" -o "$OUTPUT_FILE"

echo "Data fetched and saved to $OUTPUT_FILE"
echo "$URL"