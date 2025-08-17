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

# IBC and chain parameters
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

# # Prerequisite:: Create a hosted interchain account (ICA) on Elys from Intento

# Fetch the Trustless Agent address
trustless_agents=$($INTO_MAIN_CMD q intent list-trustless_agents --output json)
trustless_agent_address_intento=$(echo "$trustless_agents" | jq -r --arg conn_id "connection-$CONNECTION_ID" \
  '.trustless_agents[] | select(.ica_config.connection_id == $conn_id) | .agent_address')

ica_address=$(intentod --node https://rpc.intento.zone q intent interchainaccounts "$trustless_agent_address_intento" "connection-$CONNECTION_ID" | awk '{print $2}')

echo "Interchain Account Address on target chain: $ica_address"

# # # Step 1: Grant permissions (authz) for the ICA on the host chain (Elys)
$ELYS_MAIN_CMD tx authz grant $ica_address generic --msg-type "/elys.amm.MsgSwapExactAmountIn" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID  --keyring-backend test --fees 100uelys
sleep 5

# Step 2: Fund the ICA with ELYS tokens to enable functionality
FUND_TRUSTLESS_AGENT_ICA_AMOUNT=20000
fund_ica_agent=$($ELYS_MAIN_CMD tx bank send $ELYS_USER_ADDRESS $ica_address $FUND_TRUSTLESS_AGENT_ICA_AMOUNT$ELYS_DENOM --from $ELYS_USER -y  --fees 100uelys --keyring-backend test)
sleep 5

# Step 3: Create the withdrawal message to claim staking rewards. Create the bond message to stake tokens on Elys. ICA_ADDR is a placeholder that will be replaced with the actual host account ICA address ahead of execution.

msg_swap_usdc="msg_swap_usdc.json"
cat <<EOF >"$msg_swap_usdc"
{
  "@type": "/cosmos.authz.v1beta1.MsgExec",
  "msgs": [
    {
      "@type": "/elys.amm.MsgSwapExactAmountIn",
      "sender": "$ELYS_USER_ADDRESS",
      "token_in": { "denom": "ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349", "amount": "100" },
      "routes": [{"pool_id":2,"token_out_denom":"uelys"}],
      "token_out_min_amount": "1"
    }
  ],
  "grantee": "$ica_address"
}
EOF

echo "Submitting flow..."

# Step 4: Create a memo for hosted flow to be sent via IBC transfer

msg_swap_usdc_json=$(cat "$msg_swap_usdc")

# Flow metadata to include in IBC packet memo
memo='{
  "flow": {
    "msgs": ['"$msg_swap_usdc_json"'],
    "duration":"'$DURATION'",
    "interval": "'$INTERVAL'",
    "label":"DCA into Elys",
    "trustless_agent": "'$trustless_agent_address_intento'",
    "fee_limit": "20uinto, 100ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349",
    "start_at":"0",
    "owner": "'$INTO_USER_ADDRESS'",
    "fallback": "true",
    "save_responses":"true",
    "cid": "connection-'$CONNECTION_ID'"
  }
}'

echo $memo
# Step 5: Trigger the hosted flow by sending tokens with memo to INTO chain
TRANSFER_TX_RES=$($ELYS_MAIN_CMD tx ibc-transfer transfer transfer $ELYS_INTO_TRANSFER_CHANNEL $INTO_USER_ADDRESS 1000$ELYS_DENOM --fees 1000uelys --keyring-backend test \
  --memo "$memo" --from $ELYS_USER -y --chain-id $ELYS_CHAIN_ID)

echo "Flow Submitted!"
echo $TRANSFER_TX_RES