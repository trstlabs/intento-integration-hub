# 🔁 Intento Flow: Autocompound DYDX Staking Rewards

This flow allows a user to **autocompound DYDX staking rewards** from the dYdX chain. While DYDX uses the standard Cosmos SDK distribution module, its `MsgWithdrawDelegatorReward` response returns **both DYDX and USDC**. Only DYDX can be staked again, while USDC must be swapped to DYDX on the open market (not possible directly on dYdX since it only supports perpetuals).

---

## 🔧 Supported Flow Types

- ✅ **Self-Hosted**: Required for DYDX, since `MsgExec` is not supported on DYDX ICA.
- ⚠️ **Hosted Mode**: Currently **not supported** due to DYDX’s lack of `MsgExec` support for ICA accounts. See [this list](https://dydx-rest.publicnode.com//ibc/apps/interchain_accounts/host/v1/params) for more details.

To execute flows on DYDX using their current `ICA allowlist` implementation, **users must self-host an ICA account** and fund it with DYDX for gas.

---

## 🧠 Execution Strategy (Trust-Minimized Flow)

**Before Flow Starts:**
- User sends `MsgSetWithdrawAddress` to point to their **DYDX ICA address**.

### 🔄 Flow Execution on Intento

```markdown
1. 🔍 ICQ → Query ICA DYDX balance
2. 💸 MsgTransfer → From Intento to DYDX ICA: send 400 udydx for execution fees
3. 🪂 ICA:
   - MsgWithdrawDelegatorReward → receive DYDX & USDC
   - MsgDelegate → re-stake DYDX portion
   - MsgTransfer (USDC → Osmosis) with `wasm` memo → execute swap
4. 🧪 Osmosis executes swap USDC → DYDX via Skip API contract
5. 📦 Callback:
   - MsgTransfer DYDX → back to DYDX ICA
6. 🪄 ICA:
   - MsgDelegate DYDX based on ICQ value
```

---

## 🛠️ Submitting the Intento Flow

### Option 1: Via Intento CLI/API
- Submit flow JSON directly via `intento tx intent submit-flow`
- Can `intentojs` to build and submit the flow from typescript frontend

### Option 2: Via Cosmos Hub → MsgTransfer
- Use `MsgTransfer` from Cosmos Hub to Intento with a `memo` of:

```json
memo: JSON.stringify(flowMemo)
```
- This allows users to submit flows **just by sending ATOM** with the memo

---

## 📦 Packet Forwarding: Swap Execution on Osmosis

- The `MsgTransfer` from DYDX ICA → Osmosis **must include a `wasm` memo**
- This memo invokes the **Skip API Contract** on Osmosis:

```json
{
  "wasm": {
    "contract": "osmo1...",
    "msg": {
      "execute_swap": {
        "input_denom": "uusdc",
        "output_denom": "udydx",
        "receiver": "dydx1ica..."
      }
    }
  }
}
```
Example only, see [Skip API Contract](https://github.com/skip-mev/skip-go-cosmwasm-contracts/tree/main/contracts/adapters/ibc/ibc-hooks) for the actual implementation details.
---

## ⚠️ Important Notes

- ❗ **No MsgExec**: ICA on DYDX cannot use MsgExec, flows must operate directly from the ICA.
- ⛽ **Fee Funding**: Instead of manually funding the ICA, you can include a `MsgTransfer` at the **start of the flow** to send 400udydx to the ICA. This ensures sufficient gas for execution.
- 🐌 **Delayed Autocompound**: The `MsgDelegate` will act on **previous execution's swap**, since the actual swap happens after USDC is received. A delay of 1 execution loop is expected.
- 🧮 **ICQ Pre-check**: Each execution cycle starts with ICQ balance queries, which feed into `MsgDelegate` and future actions.

---

## 🔗 Trigger Monitoring

Once the flow is created, you can track it via Intento Portal:

```ts
let flowID = data.events
  .find((event) => event.type == 'flow-created')
  .attributes.find((attr) => attr.key == 'flow-id').value;

// 🔔 Alerts:
https://portal.intento.zone/alert?flowID=8

// 📊 Flow:
https://portal.intento.zone/flows/8
```

You can configure alerts for:
- Timeouts
- Errors
- Insufficient balances
- Every execution run (🕒)

---

## ✅ Summary

This flow demonstrates how to use **Intento + ICA + ICQ** to:
- Compound DYDX staking rewards
- Offload USDC via IBC swap on Osmosis
- Automate the re-stake process
- Maintain user control with minimal trust assumptions

To make the flow more seamless, DYDX can enabe AuthZ's MsgExec for ICA accounts, but this is not currently supported on DYDX.
That would mean we can more easily use the flow to autocompound rewards, and also allow users to stake DYDX again.
