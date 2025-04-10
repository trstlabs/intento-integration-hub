#!/bin/bash

# Environment variables
INTO_USER=usr1
INTO_DENOM=uinto
INTO_ADDRESS=into1wdplq6qjh2xruc7qqagma9ya665q6qhcpse4k6
OSMO_ADDRESS=osmo1wdplq6qjh2xruc7qqagma9ya665q6qhcwju3ng
ICA_ADDR=ica1wdplq6qjh2xruc7qqagma9ya665q6qhcwju3ng
HOST_DENOM=uatom # uosmo or atom ibc/
AMOUNT_DCA=1000000
AMOUNT_FEE=400
CONTRACT_ADDRESS="<CONTRACT_ADDRESS>" # Replace with the actual contract address
STREAM_ID="<STREAM_ID>"               # Replace with the stream ID

CONNECTION_ID=0
HOST_CONNECTION_ID=0 #retrieve

# Step 1: Send ATOM to the ICA address to cover fees
msg_transfer_file="msg_transfer_to_ica.json"
cat <<EOF >"$msg_transfer_file"
{
  "@type": "/cosmwasm.wasm.v1.MsgTransfer",
  "sender": "$INTO_ADDRESS",
  "receiver": "ICA_ADDR",
  "denom": "$HOST_DENOM",
  "amount": "$AMOUNT_FEE",
  "timeout_height": "0",
  "memo": "Transfer to ICA for contract execution fees"
}
EOF

# Step 3: Execute the contract message (MsgExecuteContract)
msg_dca_file="msg_dca.json"
cat <<EOF >"$msg_dca_file"
{
  "subscribe": {
    "stream_id": "$STREAM_ID",
    "operator_target": "$OSMO_ADDRESS",
    "operator": "$ICA_ADDR"
  }
}
EOF

# Step 4: Encode MsgExecuteContract to Base64
BASE64_MSG_EXECUTE=$(base64 -w 0 "$msg_dca_file")
echo "Base64 MsgExecuteContract: $BASE64_MSG_EXECUTE"


msg_execute_contract_file="msg_execute_contract_dca_streamswap.json"
cat <<EOF >"$msg_execute_contract_file"
{
  "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
  "sender": "$ICA_ADDR",
  "contract": "$CONTRACT_ADDRESS",
  "msg": '"$BASE64_MSG_EXECUTE"',
  "funds": [
    {
      "denom": "$HOST_DENOM",
      "amount": "$AMOUNT_DCA"
    }
  ]
}
EOF

msg_transfer_json=$(cat "$msg_execute_contract_file")
msg_execute_contract_json=$(cat "$msg_execute_contract_file")
# Step 5: Construct final flow with two messages

## idea: ICQ contract balance => use as condition

memo='{"flow": {"msgs": ['"$msg_transfer_json"','"$msg_execute_contract_json"'],"label":"DCA into StreamSwap stream 🌊","cid":"connection-'$CONNECTION_ID'","host_cid":"connection-'$HOST_CONNECTION_ID'","start_at":"1688295600", "owner": "'$INTO_ADDRESS'", "fallback": "true"}}'

# Step 6: Submit Flow
TX_RES=$($INTO_MAIN_CMD tx intent submit-flow --memo "$memo" --from "$INTO_USER" -y)
echo "Flow Submitted!"
echo $TX_RES
