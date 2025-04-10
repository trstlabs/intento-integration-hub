#!/bin/bash
set -o errexit -o nounset -o pipefail

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Define the directory for the aggregated JSON files
AGGREGATED_DIR="${SCRIPT_PATH}/schemas/aggregated_msgs"

# Remove the aggregated directory if it exists
rm -rf "${AGGREGATED_DIR}"
# Recreate the aggregated directory
mkdir -p "${AGGREGATED_DIR}"

# Loop through all JSON files in the msgs directory
for json_file in "${SCRIPT_PATH}/schemas/msgs"/*.json; do
    # Check if the file exists
    if [ -f "$json_file" ]; then
        # Get the file name without the extension
        file_name=$(basename "${json_file%.*}")
        
        # Extract the first characters of the file name
        prefix="${file_name%%_*}"
        
        # Create a new aggregated JSON file with the same prefix
        aggregated_file="${AGGREGATED_DIR}/${prefix}_json_msgs.json"
        
        # If the aggregated file already exists, add a comma before appending the contents
        if [ -f "$aggregated_file" ]; then
            # Add a comma to the end of the existing aggregated file
            echo -n "," >> "$aggregated_file"
            # Append the contents of the current JSON file
            cat "$json_file" >> "$aggregated_file"
        else
            # Otherwise, create the aggregated file and wrap the contents in an array of objects
            echo "[" > "$aggregated_file"
            # Append the contents of the current JSON file
            cat "$json_file" >> "$aggregated_file"
        fi
    fi
done

# Close the JSON array in the aggregated files
for aggregated_file in "${AGGREGATED_DIR}"/*.json; do
    # Check if the file exists
    if [ -f "$aggregated_file" ]; then
        # Close the JSON array
        echo "]" >> "$aggregated_file"
    fi
done

echo "Aggregated JSON schemas in $AGGREGATED_DIR"
