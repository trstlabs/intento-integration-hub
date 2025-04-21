#!/bin/bash

#########################################
# Configuration for ICA-based DCA Flow #
# Method 1: User-Owned ICA as Operator #
#########################################

# ==== ACCOUNT CONFIGURATION ====

# Local account names (for keyring / CLI access)
USER=usr1

# Bech32 addresses
INTO_ADDRESS=into18ajuj6drylfdvt4d37peexle47ljxqa5v8r6n8
OSMO_ADDRESS=osmo18ajuj6drylfdvt4d37peexle47ljxqa5t74wq8

# ==== TOKEN CONFIGURATION ====

# Native denominations on respective chains
INTO_DENOM=uinto
OSMO_DENOM=uosmo

# IBC denominations on Osmosis (after INTO → Osmosis transfer)
OSMO_INTENTO_DENOM=ibc/B677BC83C7FDC5B28C0BF843798A13498692EDE28F826DB60D5B4530C53914B2
INTO_OSMOSIS_DENOM=ibc/DD6C1EFD5BDD9A5A362A7075E60BFEBC037E28D8DD04B9D1ECF73C1298BB47AA

# ==== DCA SETTINGS ====

# StreamSwap contract + stream ID
CONTRACT_ADDRESS=osmo1wgej0zjfwg2uaaxygxz3ehv4xa5u2k2ndmcez9tjfqgktwt5t4jqmvsd9z # Replace if needed
STREAM_ID="16"

# DCA cadence
AMOUNT_DCA=100 # Amount of INTO to allocate per interval

DURATION="6000s"      # Total duration of the DCA stream
INTERVAL="600s"       # Interval between executions
START_AT="1688295600" # Start time of the DCA stream (UNIX timestamp)

# ==== IBC CONFIGURATION ====

# Osmosis (remote) side
OSMO_CONNECTION_ID=3985
OSMO_CHANNEL=channel-10363

# INTO (local) side
CONNECTION_ID=1
CHANNEL=channel-6

# ==== PREREQUISITES ====
# 1. The target Osmosis ICA must be registered (or set "register_ica": true in memo)
# 2. The user must subscribe to the StreamSwap stream (see `subscribe` msg below). In case the user has an ICA, they can set the operator to the ICA address here.
# 3. The ICA account must have funds (in INTO_OSMOSIS_DENOM) to call the contract

# ==== CONSTRUCT COSMWASM MESSAGE ====

msg_dca_file="msg_dca.json"
cat <<EOF >"$msg_dca_file"
{
  "subscribe": {
    "stream_id": "$STREAM_ID",
    "operator_target": "$OSMO_ADDRESS",
    "operator": "ICA_ADDR"   # Will be replaced with ICA address when executed
  }
}
EOF

# ==== ENCODE AND WRAP MESSAGE ====

BASE64_MSG_EXECUTE=$(base64 -w 0 "$msg_dca_file")
echo "Base64 MsgExecuteContract: $BASE64_MSG_EXECUTE"

msg_execute_contract_file="msg_execute_contract_dca_streamswap.json"
cat <<EOF >"$msg_execute_contract_file"
{
  "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
  "sender": "ICA_ADDR",  # Will be the Osmosis ICA address once registered
  "contract": "$CONTRACT_ADDRESS",
  "msg": "$BASE64_MSG_EXECUTE",
  "funds": [
    {
      "denom": "$INTO_OSMOSIS_DENOM",
      "amount": "$AMOUNT_DCA"
    }
  ]
}
EOF

# Read JSON contents for inclusion in memo
msg_execute_contract_json=$(cat "$msg_execute_contract_file")

# ==== BUILD FLOW MEMO ====

# This memo registers a new flow via Intento and also registers the ICA if needed
memo='{"flow": {
  "msgs": ['"$msg_execute_contract_json"'],
  "label": "DCA into StreamSwap stream 🌊",
  "cid": "connection-'$CONNECTION_ID'",
  "host_cid": "connection-'$OSMO_CONNECTION_ID'",
  "owner": "'$INTO_ADDRESS'",
  "duration": "'$DURATION'",
  "start_at": "'$START_AT'",
  "interval": "'$INTERVAL'",
  "fallback": "true",
  "register_ica": "true"
}}'

echo "Flow Memo:"
echo $memo

# ==== EXECUTE IBC TRANSFER TO TRIGGER FLOW CREATION ====

# Transfers INTO tokens from INTO → Osmosis to fund the execution
# This also triggers the creation of the ICA and the execution of the above message via memo
TRANSFER_TX_RES=$(./build/osmosisd tx ibc-transfer transfer transfer $OSMO_CHANNEL $INTO_ADDRESS 1000$INTO_OSMOSIS_DENOM \
  --from $USER \
  --memo "$memo" \
  -y \
  --home ./dockernet/state/osmo1 \
  --node https://rpc.osmotest5.osmosis.zone \
  --fees 1000uosmo \
  --gas 400000 \
  --chain-id osmo-test-5)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES

############################################################
# 🔧 Final Setup Steps (Manual / Optional)
#
# 1️⃣  Fund the ICA with OSMO for transaction fees:
#     ./build/osmosisd tx bank send $OSMO_USER $ICA_ADDR 100000$OSMO_DENOM ...
#
# 2️⃣  (Optional) Approve the StreamSwap operator via ICA tx if needed.
#
# 🔍 Tip: Retrieve the ICA address (self-hosted) using:
#     - CLI: intentod query intent interchainaccounts $INTO_ADDRESS connection-$CONNECTION_ID
#     - LCD: https://lcd.intento.zone/swagger/#get-/intento/intent/v1beta1/address-to-ica
############################################################
