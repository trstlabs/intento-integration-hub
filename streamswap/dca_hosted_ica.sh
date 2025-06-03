#!/bin/bash

#########################################
# Configuration for ICA-based DCA Flow  #
# Method 2: Hosted ICA as Operator      #
#########################################

# ==== CONFIGURATION ====

# CLI binary and home directory - adjust as needed
BIN="./build/osmosisd"
HOME_DIR="./dockernet/state/osmo1"

USER="testosmo"
INTO_USER_ADDRESS="into18ajuj6drylfdvt4d37peexle47ljxqa5v8r6n8"
HOST_USER_ADDRESS="osmo18ajuj6drylfdvt4d37peexle47ljxqa5t74wq8"

NODE="https://rpc.osmotest5.osmosis.zone"

# Token details
TARGET_DENOM="factory/osmo1nz7qdp7eg30sr959wvrwn9j9370h4xt6ttm0h3/ussosmo" # Example token for Osmosis
INTO_FEE_IBC_DENOM="ibc/4810C6E0DF162BD8BCEB9189DAFE25AF6B2A47323891BD3EB95365C0D2A889F6" # Fee denom for Intento + hosted account fees

# DCA parameters
CONTRACT_ADDRESS="osmo10wn49z4ncskjnmf8mq95uyfkj9kkveqx9jvxylccjs2w5lw4k6gsy4cj9l"
STREAM_ID=45
AMOUNT_DCA=100

DURATION="24h"
INTERVAL="600s"
START_AT="0"

# IBC settings
TARGET_CHAIN_ID="osmo-test-5"
TARGET_CONNECTION_ID="connection-2"
CHANNEL_TO_INTENTO="channel-10411"

# ==== FETCH HOSTED ICA ADDRESS ====

echo "Fetching hosted ICA accounts..."
HOSTED_ACCS=$(intentod --node https://rpc.intento.zone q intent list-hosted-accounts --output json)

HOSTED_ADDR=$(echo "$HOSTED_ACCS" | jq -r --arg conn_id "$TARGET_CONNECTION_ID" \
  '.hosted_accounts[] | select(.ica_config.connection_id == $conn_id) | .hosted_address')

if [ -z "$HOSTED_ADDR" ]; then
  echo "❌ Error: No hosted ICA found for connection ID $TARGET_CONNECTION_ID. Please register it first."
  exit 1
fi

echo "✅ Hosted ICA address found: $HOSTED_ADDR"

# Get the interchain account address for the hosted account on the target chain
HOSTED_ICA_ADDR=$(intentod --node https://rpc.intento.zone q intent interchainaccounts "$HOSTED_ADDR" "$TARGET_CONNECTION_ID" | awk '{print $2}')

echo "Interchain Account Address on target chain: $HOSTED_ICA_ADDR"

# ==== BUILD COSMWASM MESSAGE ====

msg_dca_file="msg_dca_hosted.json"
cat > "$msg_dca_file" <<EOF
{
  "subscribe": {
    "stream_id": $STREAM_ID,
    "operator_target": "$HOST_USER_ADDRESS",
    "operator": "ICA_ADDR"
  }
}
EOF

msg_execute_contract_file="msg_execute_contract_hosted_dca.json"
cat > "$msg_execute_contract_file" <<EOF
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
      "sender": "$HOST_USER_ADDRESS",
      "contract": "$CONTRACT_ADDRESS",
      "msg": $(cat "$msg_dca_file"),
      "funds": [
        {
          "denom": "$TARGET_DENOM",
          "amount": "$AMOUNT_DCA"
        }
      ]
    }
  ],
    "operator": "ICA_ADDR"
}
EOF

msg_execute_contract_json=$(cat "$msg_execute_contract_file")

# ==== BUILD FLOW MEMO ====

memo='{"flow": {
  "msgs": ['"$msg_execute_contract_json"'],
  "label": "DCA via hosted ICA 🎯",
  "owner": "'$INTO_USER_ADDRESS'",
  "duration": "'$DURATION'",
  "start_at": "'$START_AT'",
  "interval": "'$INTERVAL'",
  "hosted_account": "'$HOSTED_ADDR'",
  "hosted_fee_limit": "50uinto",
  "fallback": "true"
}}'

echo "Flow memo constructed:"
echo "$memo"

# ==== EXECUTE IBC TRANSFER ====

echo "Submitting IBC transfer with memo..."

TRANSFER_TX_RES=$($BIN --home "$HOME_DIR" tx ibc-transfer transfer transfer "$CHANNEL_TO_INTENTO" "$INTO_USER_ADDRESS" 1000"$INTO_FEE_IBC_DENOM" \
  --from "$USER" \
  --memo "$memo" \
  -y \
  --node "$NODE" \
  --fees 1000uosmo \
  --gas 300000 \
  --chain-id "$TARGET_CHAIN_ID")

echo "Flow submitted! Transaction result:"
echo "$TRANSFER_TX_RES"

# ==== NOTES ====
# Grant the hosted account permission to execute the contract. This is required for the hosted account to be able to execute the contract. It can be finetuned to expire after a certain time.
# On Intento, authentication is in place for hosted account to only execute messages with a valid signer so no one can execute actions on your behalf, only you. See https://docs.intento.zone/module/authentication for more details.
# In the frontend, this can be signed and broadcasted in the same transaction as the transfer for improved UX.

# osmosisd authz grant $HOSTED_ADDR generic --msg-type "/cosmwasm.wasm.v1.MsgExecuteContract" --from $USER -y