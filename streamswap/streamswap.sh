#!/bin/bash

# Environment variables
INTO_USER=usr1
OSMO_USER=usr2
INTO_ADDRESS=into18ajuj6drylfdvt4d37peexle47ljxqa5v8r6n8
OSMO_ADDRESS=osmo18ajuj6drylfdvt4d37peexle47ljxqa5t74wq8

INTO_DENOM=uinto
OSMO_DENOM=uosmo

AMOUNT_DCA=100
AMOUNT_OSMO_FEE=400
CONTRACT_ADDRESS=osmo1wgej0zjfwg2uaaxygxz3ehv4xa5u2k2ndmcez9tjfqgktwt5t4jqmvsd9z # Replace with the actual contract address
STREAM_ID="16"                                                                     # Replace with the stream ID

OSMO_INTENTO_DENOM=ibc/B677BC83C7FDC5B28C0BF843798A13498692EDE28F826DB60D5B4530C53914B2
INTO_OSMOSIS_DENOM=ibc/DD6C1EFD5BDD9A5A362A7075E60BFEBC037E28D8DD04B9D1ECF73C1298BB47AA

DURATION="6000s"
INTERVAL="600s"

OSMO_CONNECTION_ID=3985
OSMO_CHANNEL=channel-10363

CONNECTION_ID=1
CHANNEL=channel-6

# make sure the token is in the osmosis wallet
TRANSFER_TX_RES=$(./build/intentod tx ibc-transfer transfer transfer $CHANNEL $OSMO_ADDRESS 1000uinto --from $INTO_USER -y --home ./dockernet/state/into1 --node https://rpc.intento.zone)
echo $TRANSFER_TX_RES

# Step 1: Send OSMO to the ICA address to cover fees
msg_transfer_file="msg_transfer_to_ica.json"
cat <<EOF >"$msg_transfer_file"
{
  "@type": "/ibc.applications.transfer.v1.MsgTransfer",
  "sender": "$INTO_ADDRESS",
  "receiver": "ICA_ADDR",
  "source_port": "transfer",
  "source_channel": "$CHANNEL",
  "token": {
  "denom": "$OSMO_INTENTO_DENOM",
  "amount": "$AMOUNT_OSMO_FEE"
  },
  "timeout_height": {
    "revision_number": "0",
    "revision_height": "0"
  },
  "timeout_timestamp": "2526374086000000000",
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
    "operator": "ICA_ADDR"
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
  "sender": "ICA_ADDR",
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

msg_transfer_json=$(cat "$msg_transfer_file")
msg_execute_contract_json=$(cat "$msg_execute_contract_file")

# Step 5: Construct final flow with two messages

memo='{"flow": {"msgs": ['"$msg_transfer_json"','"$msg_execute_contract_json"'],"label":"DCA into StreamSwap stream 🌊","cid":"connection-'$CONNECTION_ID'","host_cid":"connection-'$OSMO_CONNECTION_ID'", "owner": "'$INTO_ADDRESS'", "duration": "'$DURATION'","interval": "'$INTERVAL'", "fallback": "true", "register_ica": "true"}}'
echo $memo

# transfer tokens for fees by self-hosted account on Osmosis (or use a hosted account)
TRANSFER_TX_RES=$(./build/osmosisd tx ibc-transfer transfer transfer $OSMO_CHANNEL $INTO_ADDRESS 4000$OSMO_DENOM --from $OSMO_USER -y --home ./dockernet/state/osmo1 --node https://rpc.osmotest5.osmosis.zone --fees 800uosmo --gas 300000 --chain-id osmo-test-5)

sleep 4

TRANSFER_TX_RES=$(./build/osmosisd tx ibc-transfer transfer transfer $OSMO_CHANNEL $INTO_ADDRESS 1000$INTO_OSMOSIS_DENOM --from $OSMO_USER --memo "$memo" -y --home ./dockernet/state/osmo1 --node https://rpc.osmotest5.osmosis.zone --fees 1000uosmo --gas 400000 --chain-id osmo-test-5)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES
