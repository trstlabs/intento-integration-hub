#!/bin/bash

INTO_DENOM=uinto
INTO_USER_ADDRESS=into1u7zn9sxz8s63ww8xwg8cl7xlmwkedq7a4ntjuv
ELYS_USER_ADDRESS=elys1u7zn9sxz8s63ww8xwg8cl7xlmwkedq7a63h35u
ELYS_USER=usr1
INTO_USER=usr1
INTO_CHAIN_ID=intento-ics-test-1
ELYS_CHAIN_ID=elysicstestnet-1
# Paths to the binaries and config
INTO_MAIN_CMD="intentod"
ELYS_MAIN_CMD="elysd"

POOL_ID=32767
VALIDATOR_ADDRESS=elysvaloper1wajd6ekh9u37hyghyw4mme59qmjllzuyaceanm
# IBC and chain parameters
CONNECTION_ID=3
HOST_CONNECTION_ID=13
ELYS_INTO_TRANSFER_CHANNEL=channel-97
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
msg_create_trustless_agent=$($INTO_MAIN_CMD tx intent create-hosted-account \
  --connection-id connection-$CONNECTION_ID \
  --host-connection-id connection-$HOST_CONNECTION_ID \
  --fee-coins-supported "1000"$INTO_DENOM, "1000"$ELYS_DENOM,"1000"$ELYS_USDC_DENOM \
  --from $INTO_USER --gas 250000 --keyring-backend test -y --chain-id $INTO_CHAIN_ID)
echo $msg_create_trustless_agent

echo "Creating Trustless Agent and retrieving..."
sleep 120 # Wait for ICA creation to propagate

# Fetch the Trustless Agent address
trustless_agents=$($INTO_MAIN_CMD q intent list-trustless_agents --output json)
trustless_agent_address_intento=$(echo "$trustless_agents" | jq -r --arg conn_id "connection-$CONNECTION_ID" \
  '.trustless_agents[] | select(.ica_config.connection_id == $conn_id) | .agent_address')

ica_address=$(intentod --node https://rpc.intento.zone q intent interchainaccounts "$trustless_agent_address_intento" "connection-$CONNECTION_ID" | awk '{print $2}')

echo "Interchain Account Address on Elys chain: $ica_address"

# Step 1: Grant permissions (authz) for the ICA on the host chain (Elys)
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.stablestake.MsgBond" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID  --keyring-backend test --fees 100uelys
sleep 5
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.estaking.MsgWithdrawElysStakingRewards" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID  --keyring-backend test --fees 100uelys
sleep 5
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.commitment.MsgStake" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID  --keyring-backend test --fees 100uelys
sleep 5

# Step 2: Fund the ICA with ELYS tokens to enable functionality
FUND_TRUSTLESS_AGENT_ICA_AMOUNT=20000
fund_ica_agent=$($ELYS_MAIN_CMD tx bank send $ELYS_USER_ADDRESS $ica_address $FUND_TRUSTLESS_AGENT_ICA_AMOUNT$ELYS_DENOM --from $ELYS_USER -y  --fees 100uelys --keyring-backend test)
sleep 5

# Step 3: Create the withdrawal message to claim staking rewards. Create the bond message to stake tokens on Elys. ICA_ADDR is a placeholder that will be replaced with the actual host account ICA address ahead of execution.

msg_withdrawal_file="msg_withdrawal.json"
cat <<EOF >"$msg_withdrawal_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.estaking.MsgWithdrawElysStakingRewards",
      "delegator_address": "$ELYS_USER_ADDRESS"
    }
  ],
  "grantee": "$ica_address"
}
EOF

# Right now the pool is full
msg_bond_usdc_file="msg_bond_usdc.json"
cat <<EOF >"$msg_bond_usdc_file"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.stablestake.MsgBond",
      "amount": "1",
      "creator": "$ELYS_USER_ADDRESS",
      "pool_id": "$POOL_ID"
    }
  ],
  "grantee": "$ica_address"
}
EOF

msg_stake_eden_file="msg_stake_eden.json"
cat <<EOF >"$msg_stake_eden"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.commitment.MsgStake",
      "amount": "1",
      "creator": "$ELYS_USER_ADDRESS",
      "asset": "ueden",
      "validator_address": "$VALIDATOR_ADDRESS"
    }
  ],
  "grantee": "$ica_address"
}
EOF

msg_stake_edenb_file="msg_stake_edenb.json"
cat <<EOF >"$msg_stake_edenb"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.commitment.MsgStake",
      "amount": "1",
      "creator": "$ELYS_USER_ADDRESS",
      "asset": "uedenb",
      "validator_address": "$VALIDATOR_ADDRESS"
    }
  ],
  "grantee": "$ica_address"
}
EOF

echo "Submitting flow..."

# Step 4: Create a memo for hosted flow to be sent via IBC transfer

msg_bond_usdc=$(cat "$msg_bond_usdc_file")
msg_stake_eden=$(cat "$msg_stake_eden_file")
msg_stake_edenb=$(cat "$msg_stake_edenb_file")
msg_withdrawal=$(cat "$msg_withdrawal_file")

# Flow metadata to include in IBC packet memo
memo='{
  "flow": {
    "msgs": ['"$msg_withdrawal"','"$msg_bond_usdc"','"$msg_stake_eden"', '"$msg_stake_edenb"'],
    "duration":"'$DURATION'",
    "interval": "'$INTERVAL'",
    "label":"Autocompound",
    "trustless_agent": "'$trustless_agent_address_intento'",
    "fee_limit": "50uinto",
    "start_at":"0",
    "owner": "'$INTO_USER_ADDRESS'",
    "fallback": "true",
    "save_responses":"true",
    "cid": "connection-'$CONNECTION_ID'",
    "conditions":{
      "feedback_loops": [{
        "response_index":0,
        "response_key": "Amount.[1].Amount",
        "msgs_index":1,
        "msg_key":"Amount",
        "value_type": "sdk.Int"
      },{
        "response_index":0,
        "response_key": "Amount.[2].Amount",
        "msgs_index":2,
        "msg_key":"Amount",
        "value_type": "sdk.Int"
      }],
      "comparisons": [{
        "response_index":0,
        "response_key": "Amount.[0].Amount",
        "operand":"1",
        "operator":4,
        "value_type": "sdk.Int"
      }]
    }
  }
}'

# Step 5: Trigger the hosted flow by sending tokens with memo to INTO chain
TRANSFER_TX_RES=$($ELYS_MAIN_CMD tx ibc-transfer transfer transfer $ELYS_INTO_TRANSFER_CHANNEL $INTO_USER_ADDRESS 1000$ELYS_DENOM --fees 1000uelys --keyring-backend test \
  --memo "$memo" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES