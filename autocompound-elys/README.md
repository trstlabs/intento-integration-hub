content for the `buildFlowMemo.ts` utility:

- 🔁 Hosted & self-hosted examples
- 📦 Packet Forwarding (PFM)
- ✉️ Flow submission via `MsgTransfer`
- 🌐 TriggerPortal integration via `flow-id` from events
- 🤝 Running a hosted account for fee abstraction (optional, depends on setup preference)
- ***

## 🧰 `buildFlowMemo.ts`

This utility generates a valid **IBC transfer memo** JSON structure for use with **Intento Flows**, wrapping custom Elys messages (like `MsgClaimRewards`, `MsgBond`, etc.) in a `MsgExec` (authz) message.

Supports:

- ✅ Hosted flows (via Interchain Accounts)
- ✅ Self-hosted flows (run on user wallet)
- ✅ Feedback loop conditions
- ✅ Value comparisons (e.g., only trigger if reward > 1 uelys)
- ✅ Integration with TriggerPortal via emitted `flow-id`

---

## 🧪 Example: Hosted ICA Flow

```ts
import { buildFlowMemo } from "./buildFlowMemo";

const hostedMemo = buildFlowMemo({
  mode: "hosted",
  label: "Autocompound 🚀",
  duration: "600s",
  owner: "into1wdplq...",
  hosted_account: "elys1ica...",
  hosted_fee_limit: [{ denom: "uelys", amount: "1000" }],
  msgs: [
    {
      "@type": "/elys.masterchef.MsgClaimRewards",
      pool_ids: ["1"],
    },
    {
      "@type": "/elys.stablestake.MsgBond",
      amount: "10000",
      creator: "elys1ica...",
      pool_id: "1",
    },
  ],
  conditions: {
    feedback_loops: [
      {
        response_index: 0,
        response_key: "Amount.[0]",
        msgs_index: 1,
        msg_key: "Amount",
        value_type: "sdk.Coin",
      },
    ],
    comparisons: [
      {
        response_index: 0,
        response_key: "Amount.[0]",
        operand: "1uelys",
        operator: 4, // LARGER_THAN
        value_type: "sdk.Coin",
      },
    ],
  },
});

console.log(hostedMemo);
```

---

## 📦 Example: With Packet Forwarding (PFM)

You can forward the memo from one chain to another (e.g., Cosmos Hub ATOM, or Noble USDC ) and use **PFM** to trigger the flow on arrival. It unwraps the asset you send and sends it over to Intento. This is useful for using a certain token for gas:

```ts
const pfmMemo = {
  forward: {
    receiver: "intento-submit-flow",
    port: "transfer",
    channel: "channel-xyz",
    timeout: "10m",
    retries: 2,
  },
  flow: hostedMemo.flow, // or self-hosted
};
```

Use this `pfmMemo` as the `memo` field in your `MsgTransfer` along with the `hostedMemo` or `selfHostedMemo`.

---

## ✉️ Submitting Flow via MsgTransfer

You submit your flow by embedding the memo inside a standard IBC `MsgTransfer`:

```ts
const msgTransfer = {
  "@type": "/ibc.applications.transfer.v1.MsgTransfer",
  sender: "into1...",
  receiver: "pfm",
  source_port: "transfer",
  source_channel: "channel-osmo",
  token: {
    denom:
      "ibc/F1B5C3489F881CC56ECC12EA903EFCF5D200B4D8123852C191A88A31AC79A8E4",
    amount: "123456",
  },
  memo: JSON.stringify(pfmMemo),
};
```

#### 🧠 Notes

Receiver can be anything.
With pfmMemo, the top-level memo must include both forward and flow sections.
ATOM can now serve as the token for the Flow Account. This is used to pay for gas cost, and can be used to send over to the destination chain as well via MsgTransfer.
---

## 🌐 TriggerPortal Integration

When the flow is submitted, the chain emits a `flow-created` event with a `flow-id`.  
You can extract this to build TriggerPortal links for monitoring:

```ts
let flowID = data.events
  .find((event) => event.type === "flow-created")
  .attributes.find((attr) => attr.key === "flow-id").value;

console.log("TriggerPortal:", {
  flow: `https://triggerportal.zone/flows/${flowID}`,
  alerts: `https://triggerportal.zone/alert?flowID=${flowID}`,
});
```

You can share these links with users:

- 🔗 **Flow Dashboard**:  
  `https://triggerportal.zone/flows/${flowID}`

- 🔔 **Flow Alerts**:  
  `https://triggerportal.zone/alert?flowID=${flowID}`

> 💡 Alerts can notify users when the flow:
>
> - Runs (e.g., every hour)
> - Encounters errors
> - Fails to execute (e.g., insufficient funds)
> - Times out or halts

Here’s a new **📚 section** you can add to the **Elys README** or documentation in the integration repo. It explains how users can **run a Hosted Account** to enable flows for others, while earning rewards or offering it as a service.

This abstracts away **gas costs on Elys** for end-users and makes running flows easier across chains.

---

## 🤝 Run a Hosted Account for Interchain Flows

Users can choose to manage their own gas on the destination chain, they can send over funds to the Self-Hosted Account, or they can use a Hosted Account.
Hosted Accounts can improve UX and reduce gas costs for users, while also providing a way to earn rewards.
**Hosted Accounts** allow anyone to **execute flows** on behalf of other users without them needing to manage gas on the destination chain (**Elys** in this case). The flow uses **authz** (authorization) to ensure users stay in full control of their assets.

---

### 🧾 Why Run a Hosted Account?

- Users submit flows from Cosmos, Osmosis, or other chains, without needing to manage gas on the destination chain (**Elys** in this case).
- You **cover gas fees on Elys**
- You can **earn INTO / ATOM rewards**
- Optionally offer it as a **paid service**

---

### 🚀 Quick Start

#### 1. Create a Hosted Account

```bash
intentod tx intent create-hosted-account \
  --connection-id connection-INTO-TO-ELY \
  --host-connection-id connection-ELY-TO-INTO \
  --fee-coins-suported "1uinto,10ibc/F1B5C3489F881CC56ECC12EA903EFCF5D200B4D8123852C191A88A31AC79A8E4" \
  --from your-into-addr
```

- `--connection-id`: the **initiator’s** IBC connection ID (e.g., from Osmosis)
- `--host-connection-id`: the **target** connection ID (e.g., to Elys)
- `--hosted-account`: the ICA address created for you on Elys (via ICA registration)
- `--fee-coins-suported`: Coins supported as fees for hosted account

Fee coins supported are a base unit for gas calculation and a denom. A gas multiplier adjustment is applied to the base unit to calculate the total fee. For example, if the base unit is `1uatom` and the adjustment is `15%%`, and there is 100000 gas required, the fee will be `150000uatom` equal to `0.15 uatom`. The multiplier adjustment can be any number in **promille** and is an on chain parameter. See the swagger docs: https://lcd.intento.zone/swagger/#get-/intento/intent/v1beta1/params for the current value. See

#### 2. Update or Rotate Hosted Account

If you’ve rotated your ICA or changed setup:

```bash
intentod tx intent update-hosted-account \
  --connection-id connection-OSMO-TO-ELY \
  --host-connection-id connection-ELY-TO-OSMO \
  --hosted-account into1hostedaccount \
  --new-admin your-new-into-admin-addr \
  --from your-into-addr
```

- `--fee-coins-suported`: Coins supported as fees for hosted account, optional here
- `--hosted-account`: the address created on Intento via create-hosted-account.
- You can retrieve this from the swagger docs: https://lcd.intento.zone/swagger/#get-/intento/intent/v1beta1/hosted-accounts/-admin-

### 🔐 Security & Permissions

- Hosted accounts **never get access to user funds**.
- Our [authentication module](https://docs.intento.zone/module/authentication) enforces that:
  - All flow actions must originate from the flow **owner’s wallet**.
  - You must have an **authz grant** for any MsgExec submitted.

In other words: users **retain full control** over their funds, and hosted accounts are only permitted to submit on their behalf if granted.

---

### 📦 Example Use Case

- A validator or relayer runs a hosted ICA on Elys.
- Users create a flow using `buildFlowMemo()` with `"mode": "hosted"` and set `hosted_account` to that validator’s ICA address.
- The hosted account signs and submits MsgExec + Msgs.
- The user only pays gas **once**, on their origin chain (e.g., Cosmos Hub).
