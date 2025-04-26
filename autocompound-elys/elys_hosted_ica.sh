#!/bin/bash


INTO_DENOM=uinto
INTO_USER_ADDRESS=into1wdplq6qjh2xruc7qqagma9ya665q6qhcpse4k6
ELYS_USER_ADDRESS=elys1wdplq6qjh2xruc7qqagma9ya665q6qhcwj9k72
ELYS_USER=eusr1

# Paths to the binaries and config
INTO_MAIN_CMD="intentod"
ELYS_MAIN_CMD="elysd"

# IBC and chain parameters
CONNECTION_ID=0
HOST_CONNECTION_ID=0
ELYS_INTO_TRANSFER_CHANNEL=channel-1
INTO_DENOM=uinto
ELYS_DENOM=uelys # could also be ibc/atom

# Flow settings
DURATION=8760h # total duration of the flow (1 year)
INTERVAL=24h   # how often to repeat the action
ICS20_AMOUNT_FOR_FLOW_ACC=1000

# Safety check for required variables
if [ -z "$INTO_USER" ] || [ -z "$ELYS_USER_ADDRESS" ] || [ -z "$DURATION" ] || [ -z "$INTERVAL" ]; then
  echo "Please set the INTO_USER, ELYS_USER_ADDRESS, DURATION, INTERVAL environment variables."
  exit 1
fi

# Prerequisite:: Create a hosted interchain account (ICA) on Elys from Intento
msg_create_hosted_account=$($INTO_MAIN_CMD tx intent create-hosted-account \
  --connection-id connection-$CONNECTION_ID \
  --host-connection-id connection-$HOST_CONNECTION_ID \
  --fee-coins-supported "10"$INTO_DENOM \
  --from $INTO_USER --gas 250000 --keyring-backend test -y)
echo $msg_create_hosted_account

echo "Creating hosted ICA and retrieving..."
sleep 120 # Wait for ICA creation to propagate

# Fetch the hosted ICA address
hosted_accounts=$($INTO_MAIN_CMD q intent list-hosted-accounts --output json)
hosted_address_intento=$(echo "$hosted_accounts" | jq -r --arg conn_id "connection-$CONNECTION_ID" \
  '.hosted_accounts[] | select(.ica_config.connection_id == $conn_id) | .hosted_address')

# Step 1: Grant permissions (authz) for the ICA on the host chain (Elys)
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.stablestake.MsgBond" --from $ELYS_USER -y
sleep 5
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.masterchef.MsgClaimRewards" --from $ELYS_USER -y
sleep 5

# Step 2: Fund the ICA with ELYS tokens to enable staking
FUND_HOSTED_ICA_AMOUNT=2000
fund_ica_hosted=$($ELYS_MAIN_CMD tx bank send $ELYS_USER_ADDRESS $ica_address $FUND_HOSTED_ICA_AMOUNT$ELYS_DENOM --from $ELYS_USER -y)
sleep 5

# Step 5: Create the bond message to stake tokens on Elys. ICA_ADDR is a placeholder that will be replaced with the actual host account ICA address ahead of execution
msg_bond_file="msg_bond.json"
cat <<EOF >"$msg_bond_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.stablestake.MsgBond",
      "amount": "10000",
      "creator": "$ELYS_USER_ADDRESS",
      "pool_id": "1"
    }
  ],
  "grantee": "ICA_ADDR"
}
EOF

# Step 3: Create the withdrawal message to claim staking rewards
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
  "grantee": "ICA_ADDR"
}
EOF

echo "Submitting flow..."

# Step 4: Create a memo for hosted flow to be sent via IBC transfer

msg_bond_json=$(cat "$msg_bond_file")
msg_withdrawal_json=$(cat "$msg_withdrawal_file")

# Flow metadata to include in IBC packet memo
memo='{
  "flow": {
    "msgs": ['"$msg_withdrawal_json"','"$msg_bond_json"'],
    "duration":"'$DURATION'",
    "label":"Autocompound 🚀",
    "hosted_account": "'hosted_address_intento'",
    "hosted_fee_limit": [{ denom: "uelys", amount: "1000" }],
    "start_at":"0",
    "owner": "'$INTO_USER_ADDRESS'",
    "fallback": "true",
    "interval": "'$INTERVAL'",
    "duration": "'$DURATION'"

  },
  "conditions":{
    "feedback_loops": [{
      "response_index":0,
      "response_key": "Amount.[0].Amount",
      "msgs_index":1,
      "msg_key":"Amount",
      "value_type": "sdk.Int"
    }],
    "comparisons": [{
      "response_index":0,
      "response_key": "Amount.[0].Amount",
      "operand":"10000",
      "operator":4,
      "value_type": "sdk.Int"
    }]
  }
}'
echo $memo

# Step 5: Trigger the hosted flow by sending tokens with memo to INTO chain
TRANSFER_TX_RES=$($ELYS_MAIN_CMD tx ibc-transfer transfer transfer $ELYS_INTO_TRANSFER_CHANNEL $INTO_USER_ADDRESS 1000$ELYS_DENOM \
  --memo "$memo" --from $ELYS_USER -y)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES


--- Final Notes ---


# You can retrieve the hosted ICA address from the output of the hosted_address command, but we do not need this and can use the ICA_ADDR placeholder
# if [ -n "$hosted_address" ]; then
#   ica_address=$($INTO_MAIN_CMD q intent interchainaccounts "$hosted_address" connection-$CONNECTION_ID)
#   ica_address=$(echo "$ica_address" | awk '{print $2}')
#   echo "Interchain Account Address: $ica_address"
# else
#   echo "No hosted ICA found for connection ID: $CONNECTION_ID"
# fi



# If we replace:
# 
# ```json
# "hosted_account": "elys1ica...",
# "hosted_fee_limit": [{ "denom": "uelys", "amount": "10" }]
# ```
# 
# with:
# 
# ```json
# "cid":"connection-'$CONNECTION_ID'",
# "host_cid":"connection-'$HOST_CONNECTION_ID'"
# ```
# 
# we switch from **hosted** to **self-hosted** mode.
#
# - In **self-hosted**, adding `"register_ica": true` to the memo **creates a self-hosted ICA** (Interchain Account), but you must fund it manually.
# - Since Elys supports AuthZ*, it's simpler and better to use the hosted account approach.
# - The only fee management needed is done via `"hosted_fee_limit"`, where you can restrict how much gas-fee budget the hosted ICA can spend by setting a multiplier limit.