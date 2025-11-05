#!/bin/bash

REPO_URL="https://github.com/cosmos/chain-registry.git"

OUTPUT_CHAIN_INFO_TESTNETS="../chain_info_testnets.json"
OUTPUT_CHAIN_INFO_MAINNETS="../chain_info_mainnets.json"
OUTPUT_ASSET_LIST_TESTNETS="../asset_list_testnets.json"
OUTPUT_ASSET_LIST_MAINNETS="../asset_list_mainnets.json"
OUTPUT_FILE_IBC="../ibc_info.json"
OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS="../ibc_ics20_memo_hooks.json"

git clone "$REPO_URL" chain-registry
cd chain-registry

echo "[" > "$OUTPUT_CHAIN_INFO_TESTNETS"
echo "[" > "$OUTPUT_CHAIN_INFO_MAINNETS"
echo "[" > "$OUTPUT_ASSET_LIST_TESTNETS"
echo "[" > "$OUTPUT_ASSET_LIST_MAINNETS"
echo "[" > "$OUTPUT_FILE_IBC"
echo "[" > "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"

filter_chain() {
    jq 'del(.codebase, .peers)' "$1"
}

# --- MAINNET chains (anything in top-level dirs not testnets/_IBC/_memo_keys)
FIRST=true
for FILE in */chain.json; do
    DIR=$(dirname "$FILE")
    case "$DIR" in
        testnets|_IBC|_memo_keys) continue;;
    esac
    if $FIRST; then
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_MAINNETS"
        FIRST=false
    else
        echo "," >> "$OUTPUT_CHAIN_INFO_MAINNETS"
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_MAINNETS"
    fi
done
echo "]" >> "$OUTPUT_CHAIN_INFO_MAINNETS"

# --- TESTNET chains
FIRST=true
for FILE in testnets/*/chain.json; do
    if $FIRST; then
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_TESTNETS"
        FIRST=false
    else
        echo "," >> "$OUTPUT_CHAIN_INFO_TESTNETS"
        filter_chain "$FILE" >> "$OUTPUT_CHAIN_INFO_TESTNETS"
    fi
done
echo "]" >> "$OUTPUT_CHAIN_INFO_TESTNETS"

# --- MAINNET assetlists
FIRST=true
for FILE in */assetlist.json; do
    DIR=$(dirname "$FILE")
    case "$DIR" in
        testnets|_IBC|_memo_keys) continue;;
    esac
    if $FIRST; then
        cat "$FILE" >> "$OUTPUT_ASSET_LIST_MAINNETS"
        FIRST=false
    else
        echo "," >> "$OUTPUT_ASSET_LIST_MAINNETS"
        cat "$FILE" >> "$OUTPUT_ASSET_LIST_MAINNETS"
    fi
done
echo "]" >> "$OUTPUT_ASSET_LIST_MAINNETS"

# --- TESTNET assetlists
FIRST=true
for FILE in testnets/*/assetlist.json; do
    if $FIRST; then
        cat "$FILE" >> "$OUTPUT_ASSET_LIST_TESTNETS"
        FIRST=false
    else
        echo "," >> "$OUTPUT_ASSET_LIST_TESTNETS"
        cat "$FILE" >> "$OUTPUT_ASSET_LIST_TESTNETS"
    fi
done
echo "]" >> "$OUTPUT_ASSET_LIST_TESTNETS"

# --- IBC metadata
FIRST=true
for FILE in _IBC/*.json; do
    if $FIRST; then
        cat "$FILE" >> "$OUTPUT_FILE_IBC"
        FIRST=false
    else
        echo "," >> "$OUTPUT_FILE_IBC"
        cat "$FILE" >> "$OUTPUT_FILE_IBC"
    fi
done
echo "]" >> "$OUTPUT_FILE_IBC"

# --- Memo hooks
FIRST=true
for FILE in _memo_keys/*.json; do
    if $FIRST; then
        cat "$FILE" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
        FIRST=false
    else
        echo "," >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
        cat "$FILE" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"
    fi
done
echo "]" >> "$OUTPUT_FILE_IBC_ICS20_MEMO_HOOKS"

cd ..
rm -rf chain-registry
