#!/bin/bash

#########################################
# Configuration for ICA-based DCA Flow #
# Method 2: Hosted ICA as Operator     #
#########################################

# ==== ACCOUNT CONFIGURATION ====

USER=usr1
INTO_USER_ADDRESS=into18ajuj6drylfdvt4d37peexle47ljxqa5v8r6n8
HOST_USER_ADDRESS=inj1wdplq6qjh2xruc7qqagma9ya665q6qhcwj9k72
# ==== TOKEN CONFIGURATION ====

TARGET_DENOM=uinj # Example token to supply for Injective
INTO_FEE_IBC_DENOM=ibc/F1B5C3489F881CC56ECC12EA903EFCF5D200B4D8123852C191A88A31AC79A8E4 # IBC denom for Intento fees incl hosted account fees
# ==== DCA SETTINGS ====

CONTRACT_ADDRESS=inj1contractxyz... # Replace with actual StreamSwap contract address
STREAM_ID="16"
AMOUNT_DCA=100

DURATION="6000s"
INTERVAL="600s"
START_AT="1688295600"

# ==== IBC CONFIGURATION ====

TARGET_CHAIN_ID=injective-1
TARGET_CONNECTION_ID=connection-123
CHANNEL_TO_INTENTO=channel-123

# ==== FETCH HOSTED ICA ADDRESS ====

HOSTED_ACCS=$($INTO_MAIN_CMD q intent list-hosted-accounts --output json)

# Use jq to filter the hosted_address based on the connection ID
HOSTED_ADDR=$(echo "$HOSTED_ACCS" | jq -r --arg conn_id "connection-$TARGET_CONNECTION_ID" '.hosted_accounts[] | select(.ica_config.connection_id == $conn_id) | .hosted_address')

if [ -z "$HOSTED_ICA_ADDR" ]; then
  echo "❌ Error: Hosted ICA not found for this connection ID. Make sure it's already registered."
  exit 1
fi

echo "✅ Hosted Account Address: $HOSTED_ADDR" # this is an into-prefixed address

# ==== CONSTRUCT COSMWASM MESSAGE ====

msg_dca_file="msg_dca_hosted.json"
cat <<EOF >"$msg_dca_file"
{
  "subscribe": {
    "stream_id": "$STREAM_ID",
    "operator_target": "$HOST_USER_ADDRESS",
    "operator": "ICA_ADDR"
  }
}
EOF

# ==== ENCODE AND WRAP MESSAGE ====

BASE64_MSG_EXECUTE=$(base64 -w 0 "$msg_dca_file")
echo "Base64 MsgExecuteContract: $BASE64_MSG_EXECUTE"

msg_execute_contract_file="msg_execute_contract_hosted_dca.json"
cat <<EOF >"$msg_execute_contract_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
        "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
        "sender": "ICA_ADDR",
        "contract": "$CONTRACT_ADDRESS",
        "msg": "$BASE64_MSG_EXECUTE",
        "funds": [
            {
            "denom": "$TARGET_DENOM",
            "amount": "$AMOUNT_DCA"
            }
        ]
    }
  ],
  "grantee": "ICA_ADDR"
}
EOF

## You may use the ICA_ADDR placeholder in the above example. It will be replaced with the actual hosted account ICA address on the host chain during the first flow execution.

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
  "fallback": "true"
}}'

echo "Flow Memo:"
echo $memo

# ==== EXECUTE IBC TRANSFER ====

TRANSFER_TX_RES=$(injectived tx ibc-transfer transfer transfer $CHANNEL_TO_INTENTO $INTO_USER_ADDRESS 1000$INTO_FEE_IBC_DENOM \
  --from $USER \
  --memo "$memo" \
  -y \
  --node https://sentry.tm.injective.network \
  --fees 1000uinj \
  --gas 300000 \
  --chain-id $TARGET_CHAIN_ID)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES

# Grant the hosted account permission to execute the contract. This is required for the hosted account to be able to execute the contract. It can be finetuned to expire after a certain time.
# On Intento, authentication is in place for hosted account to only execute messages with a valid signer so no one can execute actions on your behalf, only you. See https://docs.intento.zone/module/authentication for more details.
# In the frontend, this can be signed and broadcasted in the same transaction as the transfer for improved UX.

injectived authz grant $HOSTED_ADDR generic --msg-type "/cosmwasm.wasm.v1.MsgExecuteContract" --from $USER -y

############################################################
# 🔍 Tip: Retrieve hosted ICA address using:
#     - CLI: ./build/intentod q intent list-hosted-accounts
#     - LCD: https://lcd.intento.zone/swagger/#get-/intento/intent/v1beta1/hosted-accounts
############################################################
