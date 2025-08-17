import {
    SigningStargateClient,
    DeliverTxResponse,
  } from "@cosmjs/stargate";
  import {EncodeObject, DirectSecp256k1HdWallet } from "@cosmjs/proto-signing";
  import { MsgGrant } from "cosmjs-types/cosmos/authz/v1beta1/tx";
  import { GenericAuthorization } from "cosmjs-types/cosmos/authz/v1beta1/authz";
  import Long from "long";
 

  
  const setupClient = async () => {
    const rpcEndpoint = "https://rpc.injective.network";
    const signer = await DirectSecp256k1HdWallet.fromMnemonic(
      "your mnemonic here",
      { prefix: "inj" }
    );
    return await SigningStargateClient.connectWithSigner(rpcEndpoint, signer);
  };
  
  const main = async () => {
    // === USER CONFIG ===
    const userAddress = "inj1youraddress";
    const trustlessAgentAddress = "inj1hostedicaaddress...";
    const contract = "inj1contractxyz...";
    const agentAddress = "into1wdplq6qjh2xruc7qqagma9ya665q6qhcwj9k72";
  
    const streamId = "16";
    const denom = "uinj";
    const amountDCA = "100";
    const feeDenom = "ibc/F1B5C3489F881CC56ECC12EA903EFCF5D200B4D8123852C191A88A31AC79A8E4";
  
    const duration = "6000s";
    const interval = "600s";
    const startAt = "1688295600";
    const channel = "channel-123";
    const memoLabel = "DCA via Trustless Agent 🎯";
  
    // === FLOW MEMO OBJECT (plain JSON, not base64-encoded) ===
    const flowMemo = {
      flow: {
        label: memoLabel,
        owner: userAddress,
        trustless_agent: agentAddress,
        duration,
        interval,
        start_at: startAt,
        fallback: true,
        msgs: [
          {
            type_url: "/cosmwasm.wasm.v1.MsgExecuteContract",
            value: {
              sender: trustlessAgentAddress,
              contract,
              msg: {
                subscribe: {
                  stream_id: streamId
                },
              },
              funds: [{ denom, amount: amountDCA }],
            },
          },
        ],
      },
    };
  
    // === MSG GRANT ===
   
// Convert Date to { seconds, nanos } timestamp
const toTimestamp = (date: Date) => {
    const seconds = BigInt(Math.floor(date.getTime() / 1000));
    const nanos = (date.getTime() % 1000) * 1_000_000;
    return { seconds, nanos };
  };
  
  const grantMsg: EncodeObject = {
    typeUrl: "/cosmos.authz.v1beta1.MsgGrant",
    value: MsgGrant.fromPartial({
      granter: userAddress,
      grantee: trustlessAgentAddress,
      grant: {
        authorization: {
          typeUrl: "/cosmos.authz.v1beta1.GenericAuthorization",
          value: GenericAuthorization.encode({
            msg: "/cosmwasm.wasm.v1.MsgExecuteContract",
          }).finish(),
        },
        expiration: toTimestamp(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 1 week
      },
    }),
  };
    // === IBC TRANSFER MSG with memo ===
    const transferMsg: EncodeObject = {
      typeUrl: "/ibc.applications.transfer.v1.MsgTransfer",
      value: {
        sourcePort: "transfer",
        sourceChannel: channel,
        token: {
          denom: feeDenom,
          amount: "1000",
        },
        sender: userAddress,
        receiver: userAddress,
        timeoutTimestamp: Long.fromNumber(Date.now() * 1_000_000 + 600_000_000), // 10 min
        memo: JSON.stringify(flowMemo),
      },
    };
  
    // === COMBINE BOTH MESSAGES ===
    const client = await setupClient();
    const messages: EncodeObject[] = [grantMsg, transferMsg];
  
    const result: DeliverTxResponse = await client.signAndBroadcast(
      userAddress,
      messages,
      "auto"
    );
  
    assertIsBroadcastTxSuccess(result);
    console.log("✅ Grant + Flow submitted in a single transaction!");
  };
  
  main().catch(console.error);
  