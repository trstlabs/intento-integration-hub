# tokenstream.fun Documentation

## Overview

**tokenstream.fun** lets you stream token trades across IBC using two methods:

1. **Direct from your wallet** using `authz` grants.
2. **Via Intento chain** using **packet-forward middleware (PFM)**.

In both cases, trades route through [Skip:Go](https://skip.build) contracts on DEXes like Osmosis, leveraging IBC hooks and standardized execution paths. This gives you flexibility in timing and control while keeping execution decentralized and programmable.

## Streaming Styles

There are two **streaming styles** you can pick from:

### 1. **Split Input**

* Divides your total input into **equal portions** over time.
* Great for reducing price impact from larger trades.
* Think of it as a linear execution schedule, not classic DCA.

### 2. **Recur Input**

* Streams **smaller recurring amounts**, one per interval.
* Mimics **DCA behavior**: each chunk gets its own market price.
* Useful for buying/selling into volatility over time.

Both methods help you trade with discipline and automation, not gut instinct. You choose how precise or aggressive the flow should be.

## 🛡️ Price Guard

Each stream includes an optional **Price Guard** setting:

* Sets a **minimum output amount** you're willing to accept.
* Protects against **slippage or bad rates** during volatile markets.
* Enforced on-chain via **Skip:Go contracts** using standard swap params.

💡 *On roadmap:* Automatic **stream halt** if the price drops below your guard threshold.

## Streaming Directly (Integrated Chains)

* Works with chains that support the Cosmos permission system `authz` (e.g. Osmosis Testnet).
* One transaction creates a time-limited grant and starts the stream.
* Grant expires **10 minutes after the last execution**, minimizing risk.
* Smooth reuse of grants for back-to-back streams.


## Streaming via Intento + PFM

* Token is IBC-transferred from the **source chain to Intento** using PFM.
* Intento executes the swap on your behalf using `MsgExec` and Skip:Go.
* You must fund a **derived sender account** (displayed after stream creation) to cover execution gas.
* Lets you stream from **non-authz chains** like **Noble**.

(*On roadmap:* Auto-funding via affiliate margin or opt-in gas pooling.)



## 🚀 How to Use tokenstream.fun

Streaming is frictionless. The app detects the routing method automatically:

### **1. Select Tokens**

Pick a source and destination token.

* Examples:

  * `USDC → OSMO`
  * `OSMO → ION`
  * `ATOM → ELYS`

Routing is handled for you.

Then hit `Swap`, on supported routes, you'll see the `Go Once` and `Stream` buttons.

### **2. Configure Stream Settings**

Open the **footer** for optional controls:

* **Duration / Interval / Start Time**

  * Full control over pacing

* **Stream Mode**

  * `Split Input` or `Recur input`

* **Price Guard**

  * Slippage protection

* **Email Notifications**

  * Get alerts on each swap


### **3. Review & Start Stream**

From the **Stream** page, click **Stream** to begin.

Routing determines what happens next:

#### 🔑 If using **Authz**:

* One transaction sets a temporary grant and starts the stream.
* Grant expires 10 minutes after the last execution.

#### 🌉 If using **PFM + Intento**:

* First transaction sends your tokens via IBC to the Intento chain.
* You’ll be shown the **Intento sender account** to fund with gas tokens (e.g. OSMO or INTO).
* Once funded, the stream begins.


## 🔁 Example 1: OSMO → ION (Osmosis to Osmosis via Authz)

### Scenario:

Streaming OSMO to ION on the same chain using a direct grant.

### Setup:

* Connect Osmosis testnet wallet
* Select `OSMO → ION`
* Choose duration + interval
* Submit single transaction (includes:

  * `MsgGrant` + stream parameters)

### Behavior:

* Intento executes the flow on Osmosis using Skip:Go
* You receive ION over time
* Grant expires 10 minutes after final execution

### Requirements:

* OSMO for the trade
* OSMO for gas



## 🧵 Example 2: USDC (Noble) → OSMO (Osmosis via PFM + Intento)

### Scenario:

Stream from a **non-authz** chain (Noble) into Osmosis using PFM.

### Setup:

1. Connect Noble testnet wallet
2. Select `USDC (Noble)` → `OSMO (Osmosis)`
3. Configure stream
4. Submit transaction to start the IBC transfer

### Behavior:

* USDC is IBC-transferred from Noble to Osmosis using PFM
* Tokens land on a **derived Intento account** on Osmosis
* You fund that address with **OSMO or INTO** for gas
* Intento executes the stream into OSMO using Skip:Go

### Requirements:

* **Testnet USDC from Noble**
* **Gas on Osmosis (e.g. OSMO)** to fund the derived account
* Execution begins once account is funded



## 🧰 Testnet Setup Tips

### Get Testnet Tokens

#### 🌀 OSMO (Osmosis testnet)

* Telegram faucet: [Claim OSMO](https://t.me/c/2075185137/2462)
* Discord command:

  ```bash
  $request {your osmo1 address} osmosis-test
  ```

  Join: [Intento Discord](https://discord.com/invite/hsVf9sYyZW)



#### 💵 USDC (Noble testnet)

* Go to: [faucet.circle.com](https://faucet.circle.com/)
* Select **Noble**
* Paste Noble testnet address (`noble1...`)
* Click **Request Tokens**



*All streams use real testnet IBC packets, Skip:Go contracts, and PFM routing.*
Execution may be delayed a few blocks due to IBC confirmation.

## Notes & Limitations

* **PFM-based streams** require external funding of the derived sender account for gas.
* **Skip:Go** contracts assume a standardized IBC-Hooks and contracts.
* Native support for additional DEXes, flow types, and automated funding is in progress.
