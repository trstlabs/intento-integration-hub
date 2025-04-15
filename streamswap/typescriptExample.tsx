// @ts-nocheck
import {
    SigningStargateClient,
    assertIsBroadcastTxSuccess,
  } from "@cosmjs/stargate";
  import {
    Registry,
    AminoTypes,
    DirectSecp256k1HdWallet,
  } from "@cosmjs/proto-signing";
  import { MsgTransfer } from "cosmjs-types/ibc/applications/transfer/v1/tx";
  import { MsgExecuteContract } from "cosmjs-types/cosmwasm/wasm/v1/tx";
  import { fromUtf8, toUtf8 } from "@cosmjs/encoding";
  import Long from "long";
  
  // 🧱 Config
  const rpcEndpoint = "https://rpc.osmotest5.osmosis.zone";
  const mnemonic = "<YOUR MNEMONIC>"; 
  const prefix = "osmo";
  
  const INTO_ADDRESS = "into1wdplq6qjh2xruc7qqagma9ya665q6qhcpse4k6";
  const OSMO_ADDRESS = "osmo1wdplq6qjh2xruc7qqagma9ya665q6qhcwju3ng";
  
  const OSMO_DENOM = "uosmo";
  const AMOUNT_DCA = "1000000";
  const AMOUNT_FEE = "400";
  const CONTRACT_ADDRESS = "<CONTRACT_ADDRESS>";
  const STREAM_ID = "<STREAM_ID>";
  const OSMO_CHANNEL = "channel-6";
  const CONNECTION_ID = "1";
  const OSMO_CONNECTION_ID = "3985";
  const START_AT = "1688295600";
  
  async function main() {
    const wallet = await DirectSecp256k1HdWallet.fromMnemonic(mnemonic, {
      prefix,
    });
    const [account] = await wallet.getAccounts();
  
    const client = await SigningStargateClient.connectWithSigner(
      rpcEndpoint,
      wallet
    );
  
    // 1️⃣ MsgTransfer to ICA for contract execution fees
    const msgTransfer: MsgTransfer = {
      sourcePort: "transfer",
      sourceChannel: OSMO_CHANNEL,
      sender: INTO_ADDRESS,
      receiver: "intento-flow-module", // can be anything
      token: {
        denom: OSMO_DENOM,
        amount: AMOUNT_FEE,
      },
      timeoutHeight: {
        revisionHeight: Long.ZERO,
        revisionNumber: Long.ZERO,
      },
      timeoutTimestamp: Long.fromNumber(Date.now() * 1_000_000 + 600_000_000_000), // 10 mins
      memo: "Transfer to ICA for contract execution fees",
    };
  
    // 2️⃣ MsgExecuteContract to subscribe to DCA stream
    const contractMsg = {
      subscribe: {
        stream_id: STREAM_ID,
        operator_target: OSMO_ADDRESS,
        operator: "ICA_ADDR",  // will be auto-parsed
      },
    };
  
    const executeMsg: MsgExecuteContract = {
      sender: "ICA_ADDR", // will be auto-parsed
      contract: CONTRACT_ADDRESS,
      msg: toUtf8(JSON.stringify(contractMsg)),
      funds: [
        {
          denom: OSMO_DENOM,
          amount: AMOUNT_DCA,
        },
      ],
    };
  
    // 3️⃣ Build memo with both messages
    const flowMemo = {
      flow: {
        msgs: [
          {
            "@type": "/cosmwasm.wasm.v1.MsgTransfer",
            ...msgTransfer,
          },
          {
            "@type": "/cosmwasm.wasm.v1.MsgExecuteContract",
            sender: executeMsg.sender,
            contract: executeMsg.contract,
            msg: Buffer.from(executeMsg.msg).toString("base64"),
            funds: executeMsg.funds,
          },
        ],
        label: "DCA into StreamSwap stream 🌊",
        cid: `connection-${CONNECTION_ID}`,
        host_cid: `connection-${OSMO_CONNECTION_ID}`,
        register_ica: true,
        start_at: START_AT,
        owner: INTO_ADDRESS,
        fallback: "false",
      },
    };
  
    // 4️⃣ Final IBC MsgTransfer with memo
    const txMsg: MsgTransfer = {
      ...msgTransfer,
      memo: JSON.stringify(flowMemo),
    };
  
    const fee = {
      amount: [
        {
          denom: OSMO_DENOM,
          amount: "500", // adjust as needed
        },
      ],
      gas: "200000", // adjust for gas estimation
    };
  
    const result = await client.signAndBroadcast(account.address, [
      {
        typeUrl: "/ibc.applications.transfer.v1.MsgTransfer",
        value: txMsg,
      },
    ], fee);
  
    assertIsBroadcastTxSuccess(result);
    console.log("✅ Transaction successful! TX hash:", result.transactionHash);
  }
  
  main().catch(console.error);
  