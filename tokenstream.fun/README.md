# tokenstream.fun Documentation

## Overview

**tokenstream.fun** lets you stream token trades across IBC using two methods:

1. **Direct from your wallet** using `authz` grants.
2. **Via Intento chain** using **packet-forward middleware (PFM)**.

In both cases, trades route through [Skip:Go](https://skip.build) contracts on DEXes like Osmosis, leveraging IBC hooks and standardized execution paths. This gives you flexibility in timing and control while keeping execution decentralized and programmable.

---

## Streaming Modes

There are **two ways to stream**:

### 1. **Equal Parts**

* The full input amount is split evenly across all intervals.
* Great for **reducing price impact** across time without needing DCA.

### 2. **Stream in Bits**

* The set amount is streamed in discrete portions over time (e.g., smaller, non-uniform pieces).
* More suited for **DCA** (Dollar Cost Averaging) in or out of a position.

Both modes remove emotional decision-making from trading and provide programmatic control over execution.

---

## Trade Protection: Minimum Token Out

Each stream can include a **minimum token out** safeguard:

* Ensures the output token amount meets your expectations.
* Protects against unexpected slippage.
* Implemented directly in the **Skip:Go contract**, using standard swap parameters.

(*Upcoming:* Option to auto-cancel or halt the stream if slippage threshold is breached.)

---

## Streaming Directly (Integrated Chains)

* Use chains that support `authz` (e.g., Cosmos Hub, Osmosis).
* The grant is set up and **expires 10 minutes after the last execution**.
* Everything is included in **a single transaction**: grant + flow creation.
* Grants can be reused if not expired, making repeated use smooth.

---

## Streaming via Intento + PFM

* Token is **transferred from source chain to Intento** using PFM.
* Intento executes the flow and routes via Skip:Go on the destination chain.
* Requires separate funding of the **PFM sender account** (displayed after stream is created).
* This architecture allows streaming from **non-authz** chains and broader trade flexibility.

(*Roadmap:* Auto-funding the PFM account via affiliate fees.)


---

## 🚀 How to Use tokenstream.fun

Streaming a trade is simple. tokenstream auto-detects whether to use your wallet directly or route through Intento with PFM. Here’s how it works:

### **1. Select Tokens**

Choose the token you want to stream *from* and *to*.

* Example: `USDC → OSMO`, `ATOM → ELYS`, etc.
* The platform figures out the routing logic for you.


### **2. Configure Stream Settings**

Click the **footer** to expand configuration options:

* **Stream Mode**

  * `Equal Parts`: Split the amount evenly across time.
  * `Bits`: Smaller parts streamed at custom intervals (great for DCA).

* **Minimum Token Out**

  * Slippage guard. The stream won’t execute below this rate.

* **Duration**

  * Total length of the stream (e.g. 30 minutes, 2 hours, 1 day).

* **Interval**

  * How often to execute a portion (e.g. every 5 minutes).

* **Start At**

  * Choose to start the stream now or schedule it.

* **Email Alerts** *(optional)*

  * Add your email to receive updates when executions happen.


### **3. Review & Start Stream**

From the **Stream** page, click **"Stream"** to kick things off.

Depending on the routing method:

#### 🔑 If using **Authz**:

* You’ll approve a single transaction that:

  * Creates a temporary grant (expires 10 min after last execution).
  * Starts the stream from your wallet.

No additional setup required.

#### 🌉 If using **PFM + Intento**:

* You’ll sign an IBC transfer to a derived **Intento sender account**.
* After that, the app will prompt you to fund the derived account with gas tokens (e.g. ATOM on Osmosis).
* Intento handles scheduling and stream execution.

### ✅ You're Done!

* The stream executes based on your config.
* You'll see tokens arriving over time.
* Get notified by email (optional) or track on-chain.

---

### 🔁 Example 1: USDC → OSMO on Osmosis (via Authz)

#### Scenario:

You’re streaming USDC to OSMO, staying fully on Osmosis.

#### Setup:

* Connect your Osmosis testnet wallet.
* Select `USDC → OSMO`.
* Configure stream duration and interval.
* Approve the transaction. This includes:

  * A `MsgGrant` for execution rights.
  * The stream parameters.

#### Behavior:

* Intento executes swaps using `MsgExec` and Skip:Go.
* You receive OSMO in your wallet over time.
* Grant expires 10 minutes after the last scheduled execution.

#### Requirements:

* Fund Osmosis testnet wallet with:

  * USDC (for trade).
  * OSMO (for gas).

---

### 🧵 Example 2: OSMO on Neutron → ION on Osmosis (via PFM + Intento)

#### Scenario:

Stream OSMO from Neutron into ION on Osmosis using PFM routing and hosted execution.

#### Setup:

* Connect your Neutron testnet wallet.
* Select `OSMO → ION`.
* Configure your stream (e.g., equal parts over 1 hour).
* Sign the transaction to initiate the IBC transfer via PFM.

#### Behavior:

* OSMO is IBC-transferred from Neutron to Osmosis, wrapped in a memo.
* Tokens land on a **derived Intento account** on Osmosis.
* Intento splits the amount and executes swaps into ION using Skip\:Go.

#### Requirements:

* Fund Neutron wallet with OSMO (for sending).
* App will display the Osmosis **derived sender account** that needs to be funded with:

  * ATOM or INTO (for gas).
* Execution starts once funding is detected.

---

### 🧰 Testnet Setup Tips

* Use [Osmosis Testnet Faucet](https://faucet.osmosis.zone/) to get tokens.
* Testnet swaps use real IBC packets, PFM, and Skip\:Go test deployments.
* For PFM flows, execution may be delayed a few blocks due to IBC confirmation.

## Notes & Limitations

* **Skip:Go contracts** are assumed to follow a standard IBC-Hooks interface.
* PFM-based streams require external funding of the derived sender account.
* Non-Skip:Go messages (e.g., raw `MsgSend`) are possible but won't include trade routing.