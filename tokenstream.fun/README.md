### 🧠 **Intento Token Stream Flow for Swap Routing**
**Goal:** Expand Skip:Go by allowing a routed swap (across chains) to be streamed over time. This reduces slippage, enables DCA strategies, and wraps the swap logic in an `Intento Flow`.

---

### ✅ Conditions to Activate Intento Flow Creation
- `streamSettings.shouldStream` must be `true`
- First route operation must be a `transfer`

---

### 🛠️ Step-by-Step Process

1. **Fetch Skip Route Messages**
   - `originalRouteMsgs`: Full route from source chain to destination.
   - `routeMsgsFromDex`: Subroute starting at `toChainID` of the first transfer step (used for memo extraction and continuation).

2. **Derive Swap Flow Parameters**
   - Determine total `recurrences = duration / interval`
   - Compute `streamAmount = amountOut / recurrences` for each step in the stream.
   - Use memo from `originalRouteMsgs` to extract swap logic (PFM/IbcHooks JSON).

3. **Wrap in Streamed MsgTransfer**
   - Target: Send `streamAmount` in each interval from Intento to Osmosis.
   - Use `/ibc.applications.transfer.v1.MsgTransfer` with:
     - `sender = into1...`
     - `token.denom = ibc/<hash>`
     - `memo = memoDivideAmount(...)` to split original memo over time
     - `receiver` can be empty (Osmosis IBC Hooks handles it)

4. **Wrap Streamed Msg in Intento Flow Memo**
```json
{
  "forward": {
    "receiver": "intento-submit-flow",
    "port": "transfer",
    "channel": "<OSMO_INTO_CHANNEL>",
    "timeout": "10m",
    "retries": 2
  },
  "flow": {
    "msgs": "<streamed swap message>",
    "duration": "<total duration>",
    "interval": "<interval in seconds>",
    "start_at": "<timestamp>",
    "stop_on_fail": true,
    "owner": "into1..."
  }
}
```

5. **Send Original MsgTransfer from Source Chain**
   - Uses PFM middleware
   - `receiver: "pfm"` and `memo: <Intento flow memo>`
   - This transfers tokens from source chain to Osmosis, then into Intento which triggers the token stream.

6. **Broadcast to Source Chain**
   - Message is sent via `skipClient.executeCosmosMessage`

---

### 💡 Use Cases
- **Swap Streaming**: Break up a big routed swap into smaller parts
- **DCA Strategy**: Spread swap execution over time to reduce market impact
- **Cross-Chain Yield**: Combine with other IBC-hooks apps for automated yield or staking
