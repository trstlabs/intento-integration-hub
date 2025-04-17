#!/bin/bash

# Define the URL of the repository
REPO_URL="https://github.com/cosmos/chain-registry.git"

# Define the output file names
OUTPUT_CHAIN_INFO_TESTNETS="../chain_info_testnets.json"
OUTPUT_CHAIN_INFO_MAINNETS="../chain_info_mainnets.json"
OUTPUT_ASSET_LIST_TESTNETS="../asset_list_testnets.json"
OUTPUT_ASSET_LIST_MAINNETS="../asset_list_mainnets.json"
OUTPUT_FILE_IBC=../"ibc_info.json"
OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS="../ibc_ics20_memo_hooks.json"

# Clone the repository
git clone "$REPO_URL" chain-registry
cd chain-registry

# Initialize empty JSON arrays for both output files
echo "[" > "$OUTPUT_CHAIN_INFO_TESTNETS"
echo "[" > "$OUTPUT_CHAIN_INFO_MAINNETS"
echo "[" > "$OUTPUT_ASSET_LIST_TESTNETS"
echo "[" > "$OUTPUT_ASSET_LIST_MAINNETS"
echo "[" > "$OUTPUT_FILE_IBC"
echo "[" > "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"

# Function to filter out "codebase" and "peers" objects from "chain" objects
filter_chain() {
    jq 'del(.codebase, .peers)' "$1"
}

# Find JSON files in the chain-registry directory (including testnet)
FIRST_FILE=true
find . -type f -name "chain.json" | while read -r FILE; do
    network_type=$(jq -r '.network_type' "$FILE")
    if [ "$network_type" != "testnet" ]; then
        continue
    fi
    if [ "$FIRST_FILE" = true ]; then
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_TESTNETS"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_CHAIN_INFO_TESTNETS"
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_TESTNETS"
    fi
done

# Find JSON files excluding those in the chain-registry/testnet directory
FIRST_FILE=true
find . -type f -name "chain.json" -not -path "./testnet/*" | while read -r FILE; do
    network_type=$(jq -r '.network_type' "$FILE")
    if [ "$network_type" = "testnet" ]; then
        continue
    fi
    if [ "$FIRST_FILE" = true ]; then
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_MAINNETS"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_CHAIN_INFO_MAINNETS"
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_MAINNETS"
    fi
done


# Find JSON files in the chain-registry directory (including testnet)
FIRST_FILE=true
find . -type f -name "assetlist.json" | while read -r FILE; do
    network_type=$(jq -r '.network_type' "$FILE")
    if [ "$network_type" != "testnet" ]; then
        continue
    fi
    if [ "$FIRST_FILE" = true ]; then
        filter_chain "$FILE" >> "$OUTPUT_ASSET_LIST_TESTNETS"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_ASSET_LIST_TESTNETS"
        filter_chain "$FILE" >> "$OUTPUT_ASSET_LIST_TESTNETS"
    fi
done

# Find JSON files excluding those in the chain-registry/testnet directory
FIRST_FILE=true
find . -type f -name "assetlist.json" -not -path "./testnet/*" | while read -r FILE; do
    network_type=$(jq -r '.network_type' "$FILE")
    if [ "$network_type" = "testnet" ]; then
        continue
    fi
    if [ "$FIRST_FILE" = true ]; then
        filter_chain "$FILE" >> "$OUTPUT_ASSET_LIST_MAINNETS"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_ASSET_LIST_MAINNETS"
        filter_chain "$FILE" >> "$OUTPUT_ASSET_LIST_MAINNETS"
    fi
done


# Find JSON files in the chain-registry directory (including testnet)
FIRST_FILE=true
find . -type f -name "*.json" -path "./_IBC/*" | while read -r FILE; do
    if [ "$FIRST_FILE" = true ]; then
        cat "$FILE" >> "$OUTPUT_FILE_IBC"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_FILE_IBC"
        cat "$FILE" >> "$OUTPUT_FILE_IBC"
    fi
done


# Find JSON files in the chain-registry directory (including testnet)
FIRST_FILE=true
find . -type f -name "*.json" -path "./_memo_keys/*" | while read -r FILE; do
    if [ "$FIRST_FILE" = true ]; then
        cat "$FILE" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
        FIRST_FILE=false
    else
        echo "," >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
        cat "$FILE" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
    fi
done


# Add closing square brackets to complete the JSON arrays
echo "]" >> "$OUTPUT_CHAIN_INFO_TESTNETS"
echo "]" >> "$OUTPUT_CHAIN_INFO_MAINNETS"
echo "]" >> "$OUTPUT_ASSET_LIST_TESTNETS"
echo "]" >> "$OUTPUT_ASSET_LIST_MAINNETS"
echo "]" >> "$OUTPUT_FILE_IBC"
echo "]" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"

# Clean up by removing the cloned repository directory
cd ..
rm -rf chain-registry

echo "Aggregated JSON chain info (with testnet) into $OUTPUT_CHAIN_INFO_TESTNETS"
echo "Aggregated JSON chain info (without testnet) into $OUTPUT_CHAIN_INFO_MAINNETS"
echo "Aggregated JSON asset list (with testnet) into $OUTPUT_ASSET_LIST_TESTNETS"
echo "Aggregated JSON asset list (without testnet) into $OUTPUT_ASSET_LIST_MAINNETS"
echo "Aggregated JSON ibc info into $OUTPUT_FILE_IBC"
echo "Aggregated JSON ibc ics20 message hooks info into $OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"