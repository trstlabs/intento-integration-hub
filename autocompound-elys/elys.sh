#!/bin/bash

INTO_USER=usr1
INTO_DENOM=uinto
INTO_ADDRESS=into1wdplq6qjh2xruc7qqagma9ya665q6qhcpse4k6
HOST_ADDRESS=elys1wdplq6qjh2xruc7qqagma9ya665q6qhcwj9k72
HOST_USER=eusr1
TO_HOST_ADDRESS=elys1u20df3trc2c2zdhm8qvh2hdjx9ewh00s03qlaf # Replace with the actual recipient host_address

INTO_MAIN_CMD="./build/intentod --home dockernet/state/into1 "
CONNECTION_ID=0
HOST_DENOM=uelys     #or atom ibc/atom
HOST_CONNECTION_ID=0 #retrieve
HOST_TRANSFER_CHANNEL=channel-1
DURATION=600s #10m
INTERVAL=40s
HOST_MAIN_CMD="elysd"

ICS20_AMOUNT_FOR_FLOW_ACC=1000

# Ensure necessary environment variables are set
if [ -z "$INTO_USER" ] || [ -z "$HOST_ADDRESS" ] || [ -z "$DURATION" ] || [ -z "$INTERVAL" ]; then
  echo "Please set the INTO_USER, HOST_ADDRESS, DURATION, INTERVAL environment variables."
  exit 1
fi

# Create Hosted Account, fund
msg_create_hosted_account=$($INTO_MAIN_CMD tx intent create-hosted-account --connection-id connection-$CONNECTION_ID --host-connection-id connection-$HOST_CONNECTION_ID --fee-coins-suported "10"$INTO_DENOM --from $INTO_USER --gas 250000 --keyring-backend test -y)
echo $msg_create_hosted_account
echo "Creating hosted ICA and retrieving..."
sleep 120

hosted_accounts=$($INTO_MAIN_CMD q intent list-hosted-accounts --output json)

# Use jq to filter the hosted_address based on the connection ID
hosted_address=$(echo "$hosted_accounts" | jq -r --arg conn_id "connection-$CONNECTION_ID" '.hosted_accounts[] | select(.ica_config.connection_id == $conn_id) | .hosted_address')
if [ -n "$hosted_address" ]; then
  # Get the interchain account address
  ica_address=$($INTO_MAIN_CMD q intent interchainaccounts "$hosted_address" connection-$CONNECTION_ID)
  ica_address=$(echo "$ica_address" | awk '{print $2}')

  echo "Interchain Account Address: $ica_address"
else
  echo "No hosted ICA found for connection ID: $CONNECTION_ID"
fi

#Allow Hosted ICA
$HOST_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.stablestake.MsgBond" --from $HOST_USER -y
sleep 5
$HOST_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.masterchef.MsgClaimRewards" --from $HOST_USER -y

sleep 5

#Fund Hosted ICA
FUND_HOSTED_ICA_AMOUNT=2000

fund_ica_hosted=$($HOST_MAIN_CMD tx bank send $HOST_ADDRESS $ica_address $FUND_HOSTED_ICA_AMOUNT$HOST_DENOM --from $HOST_USER -y)
sleep 5

msg_bond_file="msg_bond.json"

cat <<EOF >"$msg_bond_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.stablestake.MsgBond",
      "amount": "10000",
      "creator": "$HOST_ADDRESS",
      "pool_id": "1"
    }
  ],
  "grantee": "$ica_address"
}
EOF

msg_withdrawal_file="msg_withdrawal.json"
cat <<EOF >"$msg_withdrawal_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.masterchef.MsgClaimRewards",
      "pool_ids": ["1"]
    }
  ],
  "grantee": "$ica_address"
}
EOF

echo "Submitting flow..."

# Flow from Intento
# Run the intentod submit-flow command
TX_RES=$($INTO_MAIN_CMD tx intent submit-flow ./$msg_withdrawal_file ./$msg_bond_file --label "Autocompound 🚀 " --duration $DURATION --interval $INTERVAL --fallback-to-owner-balance --keyring-backend test --home ./dockernet/state/into1/ --duration "168h" --interval "2400s" --hosted-account $hosted_host_address --fallback-to-owner-balance --conditions '{ "feedback_loops": [{"response_index":0,"response_key": "Amount.[0]", "msgs_index":1, "msg_key":"Amount","value_type": "sdk.Coin"}], "comparisons": [{"response_index":0,"response_key": "Amount.[0]", "operand":"1'$HOST_DENOM'", "operator":4,"value_type": "sdk.Coin"}]}' --save-responses --from "$INTO_USER" -y)
echo "Flow Submitted!"
echo $TX_RES

# Self-Hosted Flow from Elys
WITHDRAWAL_DENOM=$HOST_DENOM

msg_bond_json=$(cat "$msg_bond_file")
msg_withdrawal_json=$(cat "$msg_withdrawal_file")

memo='{"flow": {"msgs": ['"$msg_withdrawal_json"','"$msg_bond_json"'],"duration":"'$DURATION'","label":"Autocompound 🚀","cid":"connection-'$CONNECTION_ID'","host_cid":"connection-'$HOST_CONNECTION_ID'","start_at":"0", "owner": "'$INTO_ADDRESS'", "fallback": "true"}, "conditions":{ "feedback_loops": [{"response_index":0,"response_key": "Amount.[0]", "msgs_index":1, "msg_key":"Amount","value_type": "sdk.Coin"}], "comparisons": [{"response_index":0,"response_key": "Amount.[0]", "operand":"1'$WITHDRAWAL_DENOM'", "operator":4,"value_type": "sdk.Coin"}]}}'
echo $memo

#with INTO token in this case, and this can be the same for ATOM token from Elys routed through the Hub via packet forward memo (see README).
TRANSFER_TX_RES=$($HOST_MAIN_CMD tx ibc-transfer transfer transfer $HOST_TRANSFER_CHANNEL $INTO_ADDRESS 1000ibc/F1B5C3489F881CC56ECC12EA903EFCF5D200B4D8123852C191A88A31AC79A8E4 --memo "$memo" --from $HOST_USER -y)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES
