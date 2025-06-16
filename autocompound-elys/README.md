Here’s a revised version of the README that integrates the **DCA Flow** with an emphasis on driving volume to Elys, and promotes the **submit button** as the preferred integration pattern:

---

# ⚡ Intento Flows for Autocompounding & DCA on Elys

This documentation showcases how to automate cross-chain actions on **Elys** using **Intento Flows** — supporting both **autocompounding rewards** and **DCA (dollar-cost averaging) flows**. These flows leverage **authz**, **IBC**, and **trigger conditions**, and can be submitted via a single **IBC transfer**.

---

## ✨ What’s Included

* 🔁 **Hosted & Self-Hosted Flows** – Run flows using a hosted ICA (Intento-managed) or directly from user wallets.
* 🧠 **Flow Conditions** – Automate based on reward thresholds, time intervals, or execution outcomes (feedback loops).
* 🌐 **Intento Portal Integration** – Get flow monitoring and alerts for users in real-time.
* 🧪 **Intento Portal Submi Integration** – Preferable UX pattern: one-click submission via dynamic URL with embedded memo.
---

## 🚀 Intento Portal Submit page (Preferred Integration)

With Intento Portal Submit, the flow can be configured via  a **dynamic URL** where you can include user-specific inputs (like `token_in`) while keeping all other values preconfigured. This is the easiest way to integrate on the frontend. 

The page can be [customized](https://docs.intento.zone/module/submit-page) with a custom image, background color, and more.

### Static parameter suggestions:

* `duration`: e.g. 1 week `"604800000"`, or 1 month `"2678400000"`
* `interval`: e.g. 1 day `"86400000"` or 1 week `"604800000"`
* `fee_coin_limit`: e.g. `[{ denom: "ibc/elys", amount: "10000" }]` this is the limit the fee amount the hosted ICA can spend per execution
* `label`: e.g. `"DCA Flow"`
* `feeCoinLimit`: e.g. `ibc/F1B5...` (Elys uelys)

### Dynamic parameter suggestions:

* DCA: `token_in`
* Autocompound: `validator_address` 

### Styling parameter suggestions:

Dark theme:
imageUrl=https://raw.githubusercontent.com/elys-network/elys-brand-assets/refs/heads/main/logos/Primary%20Logo%20-%20Curved%20Edge/Logo1.png&chain=elysicstestnet-1&theme="dark"&bgColor=#28303b

Fully black background:
imageUrl=https://raw.githubusercontent.com/elys-network/elys-brand-assets/refs/heads/main/logos/Primary%20Logo%20-%20Curved%20Edge/Logo5.png&chain=elysicstestnet-1&theme="dark"&bgColor=#000000


### Integration Pattern:

Trigger the submit page URL from a **button in the Elys UI**. This pattern is scalable and avoids complex client-side flow memo generation.

---

## 💸 Example: DCA Flow Memo

This can be used for submitting a DCA flow via your own frontend instead of the Intento Portal submit page if a direct integration is preferred.

```ts
const dcaAndBondMemo = buildFlowMemo({
  mode: "hosted",
  label: "DCA Flow 🚰",
  duration: "3600s", // total active time
  interval: "300s",  // frequency
  owner: "cosmos1...",
  hosted_account: "elys1ica...",
  hosted_fee_limit: [{ denom: "uelys", amount: "1000" }],
  msgs: [
    {
      "@type": "/elys.amm.MsgSwapExactAmountIn",
      token_in: {
        denom: "uelys",
        amount: "10000",
      },
      routes: [
        {
          pool_id: "1",
          token_out_denom: "ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349",
        },
      ],
      sender: "elys1ica...",
    },
    {
      "@type": "/elys.stablestake.MsgBond",
      amount: "10000",
      creator: "elys1ica...",
      pool_id: "1",
    },
  ],
});
```

---

## ✉️ Submitting via IBC Transfer

Both autocompound and DCA flows are triggered with a single `MsgTransfer`, where the `memo` is the output of `buildFlowMemo()`.

```ts
const msgTransfer = {
  "@type": "/ibc.applications.transfer.v1.MsgTransfer",
  sender: "cosmos1...",
  receiver: "",
  source_port: "transfer",
  source_channel: "channel-elys-intento",
  token: {
    denom: "uelys",
    amount: "123456",
  },
  memo: JSON.stringify(dcaAndBondMemo),
};
```

---

## 📣 Why DCA Flows in Elys are Useful

Including DCA flows helps drive **consistent volume** to Elys by making token inflows and swap activity programmatic.
Unlike one-off swaps, a DCA flow:

* **Brings steady volume** to Elys
* **Incentivizes token holders** to regularly buy and stake ELYS
* **Simplifies the UX** with a one-click submit button

This is ideal for:

* New user onboarding
* Long-term ATOM and ELYS holders
* Offering automated strategies to users