# StreamSwap: DCA Into a Stream

This guide outlines how to integrate a **DCA (Dollar-Cost Averaging)** feature into a StreamSwap stream. It includes technical flows, UX patterns, and code references to streamline implementation across different blockchains.

---

## ✨ Idea: Early Pledge Unlocks DCA

Participants who **pledge early** (e.g. 50 ATOM or 200 USDC) before a stream starts unlock the ability to **DCA into the stream**. Once unlocked, these participants can continue to add funds gradually over time, as the sale progresses. They would receive the benefit of **purchasing tokens at different price points**, which helps mitigate risk from potential price fluctuations during the stream.

### **Unique Value Proposition:**

This approach is valuable both for the stream owner and for the participants. Here's why:

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

A **“Start DCA” button** can be enabled in the frontend once the early pledge is complete.  
On click, this triggers the corresponding flow on Intento via a `MsgTransfer` with `flow` memo.

---

## 🛠 Code Examples

Integration-ready scripts and examples:

- `dca_hosted_ica.sh` – Bash: Hosted ICA setup
- `dca_self-hosted_ica.sh` – Bash: Self-hosted ICA setup
- `dca_hosted_ica.ts` – TypeScript: Hosted ICA with `MsgExec` support for optimal UX

---

### **Technical Options for DCA Integration**

The following table compares different implementation ideas for enabling DCA and withdrawal functionality during a stream:

| **Method**                   | **DCA** | **Withdraw** | **Needs ICA Funding?** | **Complexity** | **UX Quality** | **Notes**                                                                                              |
| ---------------------------- | ------- | ------------ | ---------------------- | -------------- | -------------- | ------------------------------------------------------------------------------------------------------ |
| **1. ICA (user-owned)**      | ✅      | ✅           | ✅                     | Medium         | ❌ Poor        | Requires pre-setup ICA address. Currently not compatible with Authz on Osmosis.                        |
| **2. IBC Hooks (user addr)** | ✅      | ❌           | ❌                     | Low            | ✅ Good        | Uses user's Osmosis address. Requires smart contract for proper handling.                              |
| **3. ICA + ICQ**             | ✅      | ✅           | ✅                     | 🔺 High        | ❌ Poor        | Uses interchain accounts with queries to track remote balances. Complex.                               |
| **4. Hosted ICA + MsgExec**  | ✅      | ✅           | ❌                     | ✅ Low         | ✅✅ Excellent | Easiest user experience. Requires MsgExec support from Osmosis. Supported on the Injective blockchain. |


### Self-Hosted ICA Flow

For self-hosted ICAs, the user must:

1. **Create the ICA** on Intento chain. Then subscribe to the stream, with the ICA address as the operator.
2. **Subscribe to the stream** by sending funds with the `flow` memo to Intento with MsgExecuteContract as a message. ICA address is set as the operator and is auto-parsed.

 **Notes:**

- ICA must be pre-created and funded by the user.
- Works on any chain with ICA support, but adds user-side friction.


### Hosted ICA Flow

In the hosted ICA setup:

1. The user creates a flow on Intento, e.g. via a `flow` memo in a `MsgTransfer` message from the host chain.
2. The flow uses a **hosted interchain account** (for host chain fees to be managed by a team).
3. Execution (e.g., add to position) is done using `MsgExec` based on AuthZ permissions. In the frontend, this can be signed and broadcasted in the same transaction as the MsgTransfer for improved UX.

**Notes:**

- No user-side ICA setup or funding required.
- Easier UX and fully managed, but requires trust in the hosted operator.

  As this requires full AuthZ support for ICAs, this is currently not available on Osmosis. On Intento, authentication is in place for hosted account to only execute messages with a valid signer so no one can execute actions on your behalf, only you. See https://docs.intento.zone/module/authentication for more details.

