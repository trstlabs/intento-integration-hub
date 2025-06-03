# StreamSwap: DCA Into a Stream

This guide outlines how to integrate a **DCA (Dollar-Cost Averaging)** feature into a StreamSwap stream. It includes technical flows, UX patterns, and code references to streamline implementation across different blockchains.

## ✨ Idea: Early Pledge Unlocks DCA

Participants who **pledge early** (e.g. 50 ATOM or 200 USDC) before a stream starts unlock the ability to **DCA into the stream**. Once unlocked, these participants can continue to add funds gradually over time, as the sale progresses. They get the benefit of **purchasing tokens at different price points**, mitigating risk from price swings during the stream.

### **Unique Value Proposition:**

This approach is valuable both for stream owners and participants:

#### **For Stream Owners:**

1. **Increased Initial Commitment**
2. **Longer Participation & Continued Engagement**
3. **Predictable Stream Dynamics**
4. **Attractive Offer for Participants**

#### **For Participants (Early Subscribers):**

1. **Risk Mitigation with DCA**
2. **Flexibility in Investment**
3. **Potential Better Allocation**
4. **Incentivized Participation**

### **Potential Benefits of the Strategy:**

1. **Increased Liquidity for the Stream**
2. **More Balanced Token Distribution**
3. **Attracts a Larger Pool of Participants**
4. **Enhanced User Engagement**

## Initiating the Flow from the UI

A **“Start DCA” button** can be enabled in the frontend once the early pledge is complete. Clicking this triggers the flow on Intento via a `MsgTransfer` with a `flow` memo.

> **Pro tip:** Instead of manually building and submitting transactions, you can now leverage our **Submit Page** for easy flow initiation.
> This page abstracts all the complexity and guides the user through submitting flows with minimal friction.
> Check out the detailed usage and integration instructions in [submit_url.md](submit_url.md).

## 🛠 Code Examples

Integration-ready scripts and examples:

- `dca_hosted_ica.sh` – Bash: Hosted ICA setup
- `dca_self-hosted_ica.sh` – Bash: Self-hosted ICA setup
- `dca_hosted_ica.ts` – TypeScript: Hosted ICA with `MsgExec` support for optimal UX
- [submit_url.md](submit_url.md) – Detailed UX guide for the new **Submit Page**

### **Technical Options for DCA Integration**

| **Method**                   | **DCA** | **Withdraw** | **Needs ICA Funding?** | **Complexity** | **UX Quality** | **Notes**                                                                                              |
| ---------------------------- | ------- | ------------ | ---------------------- | -------------- | -------------- | ------------------------------------------------------------------------------------------------------ |
| **1. ICA (user-owned)**      | ✅      | ✅           | ✅                     | Medium         | ❌ Poor        | Requires pre-setup ICA address. Currently not compatible with Authz on Osmosis.                        |
| **2. IBC Hooks (user addr)** | ✅      | ❌           | ❌                     | Low            | ✅ Good        | Uses user's Osmosis address. Requires smart contract for proper handling.                              |
| **3. ICA + ICQ**             | ✅      | ✅           | ✅                     | 🔺 High        | ❌ Poor        | Uses interchain accounts with queries to track remote balances. Complex.                               |
| **4. Hosted ICA + MsgExec**  | ✅      | ✅           | ❌                     | ✅ Low         | ✅✅ Excellent | Easiest user experience. Requires MsgExec support from Osmosis. Supported on the Injective blockchain. |

### Self-Hosted ICA Flow

1. Create the ICA on Intento chain.
2. Subscribe to the stream using the ICA address as operator.
3. Send funds with `flow` memo to Intento with MsgExecuteContract as a message, auto-parsing the ICA operator.

**Notes:**

- ICA must be pre-created and funded by the user.
- Works on any ICA-supporting chain but adds user friction.

### Hosted ICA Flow

1. Create a flow on Intento via a `flow` memo in a `MsgTransfer` from the host chain.
2. Use a **hosted interchain account** to manage host chain fees.
3. Execute actions with `MsgExec` via AuthZ permissions, which can be signed and broadcast in the same transaction for better UX.

**Notes:**

- No user-side ICA setup or funding needed.
- Better UX but requires trust in the hosted operator.
- Full AuthZ support for ICAs required, currently not available on Osmosis.
- On Intento, hosted accounts only execute messages signed by you. See [Intento Auth Documentation](https://docs.intento.zone/module/authentication) for details.
