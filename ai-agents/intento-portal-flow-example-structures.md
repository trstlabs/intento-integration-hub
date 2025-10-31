
# TWAP-Triggered DCA Flow Template

## 🔍 Overview
This is a reusable **Intento Portal flow template** for executing DCA (Dollar Cost Averaging) swaps on Osmosis, **conditioned on TWAP (Time-Weighted Average Price)** falling below a given threshold.

---

## 📥 Flow Configuration

### 🔁 Interval
- **Every 24 hours** (86,400,000 ms)

---

## 🧠 TWAP Condition Trigger

```json
{
  "valueType": "osmosistwapv1beta1.TwapRecord.P0LastSpotPrice",
  "operator": 3,
  "operand": "0.01",
  "icqConfig": {
    "chainId": "osmosis-1",
    "connectionId": "connection-1",
    "timeoutPolicy": 2,
    "timeoutDuration": {
      "seconds": "120"
    },
    "queryType": "store/twap/key",
    "queryKey": "recent_twap|{{ pool_id }}|{{ token_in_denom }}|{{ token_out_denom }}"
  }
}
```

---

## 🧾 JSON Message Template

```json
{
  "typeUrl": "/cosmos.authz.v1beta1.MsgExec",
  "value": {
    "grantee": "into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7",
    "msgs": [
      {
        "typeUrl": "/osmosis.gamm.v1beta1.MsgSwapExactAmountIn",
        "value": {
          "sender": "Your osmo address",
          "routes": [
            {
              "poolId": "{{ pool_id }}",
              "tokenOutDenom": "{{ token_out_denom }}"
            }
          ],
          "tokenIn": {
            "denom": "{{ token_in_denom }}",
            "amount": "{{ amount }}"
          },
          "tokenOutMinAmount": "1"
        }
      }
    ]
  }
}
```

---

## ⚙️ Automation + Agent

```json
{
  "trustlessAgent": {
    "agentAddress": "into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7",
    "connectionId": "connection-1",
    "feeLimit": [
      {
        "denom": "uinto",
        "amount": "20000"
      }
    ]
  },
  "configuration": {
    "saveResponses": true,
    "updatingDisabled": false,
    "stopOnSuccess": true,
    "stopOnFailure": false,
    "stopOnTimeout": true,
    "walletFallback": true
  },
}
```

---

## 🪄 Placeholders

| Placeholder | Explanation |
|------------|-------------|
| `Your address` | Automatically replaced by the user's address. |
| `Your osmo address` | Replaced by user's Osmosis address. |
| `Your Intento address` | Replaced by user's Intento trustless agent address. |
| `{{ pool_id }}` | Osmosis pool ID (e.g., 1, 560, 3138). |
| `{{ token_in_denom }}` | Input token denom (e.g., IBC denom). |
| `{{ token_out_denom }}` | Output token denom. |
| `{{ amount }}` | Input token amount (in base units). |

---

## 🔗 Example Intento Portal Link

[DCA into INTO if TWAP < 0.01](https://portal.intento.zone/build?flowInput=%7B%22duration%22%3A-659%2C%22interval%22%3A86400000%2C%22msgs%22%3A%5B%22%7B%5Cn++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.authz.v1beta1.MsgExec%5C%22%2C%5Cn++%5C%22value%5C%22%3A+%7B%5Cn++++%5C%22grantee%5C%22%3A+%5C%22osmo1lm4lt7nnp7ma9rvaq843y59c4qhqngcekm6x70k7eyev3ykucupswwqrsn%5C%22%2C%5Cn++++%5C%22msgs%5C%22%3A+%5B%5Cn++++++%7B%5Cn++++++++%5C%22typeUrl%5C%22%3A+%5C%22%2Fosmosis.gamm.v1beta1.MsgSwapExactAmountIn%5C%22%2C%5Cn++++++++%5C%22value%5C%22%3A+%7B%5Cn++++++++++%5C%22sender%5C%22%3A+%5C%22osmo17yhjytau6zukq6g0wc8ynzm90tnn3qhzc9wcfk%5C%22%2C%5Cn++++++++++%5C%22routes%5C%22%3A+%5B%5Cn++++++++++++%7B%5Cn++++++++++++++%5C%22poolId%5C%22%3A+%5C%223138%5C%22%2C%5Cn++++++++++++++%5C%22tokenOutDenom%5C%22%3A+%5C%22ibc%2FBE072C03DA544CF282499418E7BC64D38614879B3EE95F9AD91E6C37267D4836%5C%22%5Cn++++++++++++%7D%5Cn++++++++++%5D%2C%5Cn++++++++++%5C%22tokenIn%5C%22%3A+%7B%5Cn++++++++++++%5C%22denom%5C%22%3A+%5C%22ibc%2F498A0751C798A0D9A389AA3691123DADA57DAA4FE165D5C75894505B876BA6E4%5C%22%2C%5Cn++++++++++++%5C%22amount%5C%22%3A+%5C%221000000%5C%22%5Cn++++++++++%7D%2C%5Cn++++++++++%5C%22tokenOutMinAmount%5C%22%3A+%5C%221%5C%22%5Cn++++++++%7D%5Cn++++++%7D%5Cn++++%5D%5Cn++%7D%5Cn%7D%22%5D%2C%22conditions%22%3A%7B%22feedbackLoops%22%3A%5B%5D%2C%22comparisons%22%3A%5B%7B%22flowId%22%3A%220%22%2C%22responseIndex%22%3A0%2C%22responseKey%22%3A%22%22%2C%22valueType%22%3A%22osmosistwapv1beta1.TwapRecord.P0LastSpotPrice%22%2C%22operator%22%3A3%2C%22operand%22%3A%220.01%22%2C%22differenceMode%22%3Afalse%2C%22icqConfig%22%3A%7B%22connectionId%22%3A%22connection-1%22%2C%22chainId%22%3A%22osmosis-1%22%2C%22timeoutPolicy%22%3A2%2C%22timeoutDuration%22%3A%7B%22seconds%22%3A%22120%22%2C%22nanos%22%3A0%7D%2C%22queryType%22%3A%22store%2Ftwap%2Fkey%22%2C%22queryKey%22%3A%22cmVjZW50X3R3YXB8MDAwMDAwMDAwMDAwMDAwMDMxMzh8aWJjLzQ5OEEwNzUxQzc5OEEwRDlBMzg5QUEzNjkxMTIzREFEQTU3REFBNEZFMTY1RDVDNzU4OTQ1MDVCODc2QkE2RTR8aWJjL0JFMDcyQzAzREE1NDRDRjI4MjQ5OTQxOEU3QkM2NEQzODYxNDg3OUIzRUU5NUY5QUQ5MUU2QzM3MjY3RDQ4MzY%3D%22%2C%22response%22%3A%7B%7D%7D%7D%5D%2C%22stopOnSuccessOf%22%3A%5B%5D%2C%22stopOnFailureOf%22%3A%5B%5D%2C%22skipOnFailureOf%22%3A%5B%5D%2C%22skipOnSuccessOf%22%3A%5B%5D%2C%22useAndForComparisons%22%3Afalse%7D%2C%22configuration%22%3A%7B%22saveResponses%22%3Atrue%2C%22updatingDisabled%22%3Afalse%2C%22stopOnSuccess%22%3Afalse%2C%22stopOnFailure%22%3Atrue%2C%22stopOnTimeout%22%3Afalse%2C%22walletFallback%22%3Atrue%7D%2C%22connectionId%22%3A%22%22%2C%22trustlessAgent%22%3A%7B%22agentAddress%22%3A%22into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7%22%2C%22feeLimit%22%3A%5B%7B%22denom%22%3A%22uinto%22%2C%22amount%22%3A%2220000%22%7D%5D%2C%22connectionId%22%3A%22connection-1%22%7D%2C%22label%22%3A%22DCA+into+INTO+if+price+%3C+0.01%22%2C%22chainId%22%3A%22osmosis-1%22%7D)

---

## ➕ Add More Examples

To extend this template, duplicate the JSON and replace:
- `poolId`
- `tokenIn/tokenOut denom`
- `amount`
- `comparison operand` (e.g. change from `0.01` to `0.05`)

Happy automating 🚀

---

## ♻️ Autocompound Flow Example

**Label:** `Autocompound if rewards > 1 OSMO`  
[Open on Intento Portal](https://portal.intento.zone/build?flowInput=%7B%22duration%22%3A-382%2C%22interval%22%3A86400000%2C%22msgs%22%3A%5B%22%7B%5Cn++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.authz.v1beta1.MsgExec%5C%22%2C%5Cn++%5C%22value%5C%22%3A+%7B%5Cn++++%5C%22grantee%5C%22%3A+%5C%22osmo1lm4lt7nnp7ma9rvaq843y59c4qhqngcekm6x70k7eyev3ykucupswwqrsn%5C%22%2C%5Cn++++%5C%22msgs%5C%22%3A+%5B%5Cn++++++%7B%5Cn++++++++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.distribution.v1beta1.MsgWithdrawDelegatorReward%5C%22%2C%5Cn++++++++%5C%22value%5C%22%3A+%7B%5Cn++++++++++%5C%22delegatorAddress%5C%22%3A+%5C%22osmo1ghwyuy8jyvuegv59s89q4gd0hsengruanml7yd%5C%22%2C%5Cn++++++++++%5C%22validatorAddress%5C%22%3A+%5C%22osmovaloper14n8pf9uxhuyxqnqryvjdr8g68na98wn5amq3e5%5C%22%5Cn++++++++%7D%5Cn++++++%7D%5Cn++++%5D%5Cn++%7D%5Cn%7D%22%2C%22%7B%5Cn++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.authz.v1beta1.MsgExec%5C%22%2C%5Cn++%5C%22value%5C%22%3A+%7B%5Cn++++%5C%22grantee%5C%22%3A+%5C%22osmo1lm4lt7nnp7ma9rvaq843y59c4qhqngcekm6x70k7eyev3ykucupswwqrsn%5C%22%2C%5Cn++++%5C%22msgs%5C%22%3A+%5B%5Cn++++++%7B%5Cn++++++++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.staking.v1beta1.MsgDelegate%5C%22%2C%5Cn++++++++%5C%22value%5C%22%3A+%7B%5Cn++++++++++%5C%22delegatorAddress%5C%22%3A+%5C%22osmo1ghwyuy8jyvuegv59s89q4gd0hsengruanml7yd%5C%22%2C%5Cn++++++++++%5C%22validatorAddress%5C%22%3A+%5C%22osmovaloper14n8pf9uxhuyxqnqryvjdr8g68na98wn5amq3e5%5C%22%2C%5Cn++++++++++%5C%22amount%5C%22%3A+%7B%5Cn++++++++++++%5C%22denom%5C%22%3A+%5C%22uosmo%5C%22%2C%5Cn++++++++++++%5C%22amount%5C%22%3A+%5C%221000000%5C%22%5Cn++++++++++%7D%5Cn++++++++%7D%5Cn++++++%7D%5Cn++++%5D%5Cn++%7D%5Cn%7D%22%5D%2C%22conditions%22%3A%7B%22feedbackLoops%22%3A%5B%7B%22flowId%22%3A%220%22%2C%22responseIndex%22%3A0%2C%22responseKey%22%3A%22Amount.%5B-1%5D%22%2C%22msgsIndex%22%3A1%2C%22msgKey%22%3A%22Amount%22%2C%22valueType%22%3A%22sdk.Coin%22%2C%22differenceMode%22%3Afalse%7D%5D%2C%22comparisons%22%3A%5B%7B%22flowId%22%3A%220%22%2C%22responseIndex%22%3A0%2C%22responseKey%22%3A%22Amount.%5B-1%5D%22%2C%22valueType%22%3A%22sdk.Coin%22%2C%22operator%22%3A4%2C%22operand%22%3A%221000000uosmo%22%2C%22differenceMode%22%3Afalse%7D%5D%2C%22stopOnSuccessOf%22%3A%5B%5D%2C%22stopOnFailureOf%22%3A%5B%5D%2C%22skipOnFailureOf%22%3A%5B%5D%2C%22skipOnSuccessOf%22%3A%5B%5D%2C%22useAndForComparisons%22%3Afalse%7D%2C%22configuration%22%3A%7B%22saveResponses%22%3Atrue%2C%22updatingDisabled%22%3Afalse%2C%22stopOnSuccess%22%3Afalse%2C%22stopOnFailure%22%3Atrue%2C%22stopOnTimeout%22%3Afalse%2C%22walletFallback%22%3Atrue%7D%2C%22connectionId%22%3A%22%22%2C%22trustlessAgent%22%3A%7B%22agentAddress%22%3A%22into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7%22%2C%22feeLimit%22%3A%5B%7B%22denom%22%3A%22uinto%22%2C%22amount%22%3A%2220000%22%7D%5D%2C%22connectionId%22%3A%22connection-1%22%7D%2C%22label%22%3A%22Autocompound+if+rewards+%3E+1+OSMO%22%2C%22chainId%22%3A%22osmosis-1%22%7D)

### 🔁 Automation
Runs every 24 hours. Uses a trustless agent and performs 2 actions if rewards exceed 1 OSMO:

1. **Withdraw staking rewards**
2. **Delegate the withdrawn amount back to the validator**

---

### 🧠 Condition Logic

```json
{
  "valueType": "sdk.Coin",
  "operator": 4, // ">="
  "operand": "1000000uosmo",
  "responseKey": "Amount.[-1]",
  "flowId": "0",
  "responseIndex": 0
}
```

---

### 🧾 Messages Executed

#### Step 1: Withdraw Rewards

```json
{
  "typeUrl": "/cosmos.authz.v1beta1.MsgExec",
  "value": {
    "grantee": "into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7",
    "msgs": [
      {
        "typeUrl": "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward",
        "value": {
          "delegatorAddress": "Your osmo address",
          "validatorAddress": "Your validator address"
        }
      }
    ]
  }
}
```

#### Step 2: Re-delegate

```json
{
  "typeUrl": "/cosmos.authz.v1beta1.MsgExec",
  "value": {
    "grantee": "into1mc2gk8d58qn4kwf765yf8s08lht0ely2x4w3tnxn5rcwclelklcqkq2tv7",
    "msgs": [
      {
        "typeUrl": "/cosmos.staking.v1beta1.MsgDelegate",
        "value": {
          "delegatorAddress": "Your osmo address",
          "validatorAddress": "Your validator address",
          "amount": {
            "denom": "uosmo",
            "amount": "1000000"
          }
        }
      }
    ]
  }
}
```

---

### 🔐 Agent and Config

```json
{
  "trustlessAgent": {
    "agentAddress": "atom agent",
    "connectionId": "connection-1",
    "feeLimit": [
      {
        "denom": "uinto",
        "amount": "20000"
      }
    ]
  },
  "configuration": {
    "saveResponses": true,
    "updatingDisabled": false,
    "stopOnSuccess": true,
    "stopOnFailure": false,
    "stopOnTimeout": true,
    "walletFallback": true
  },
}
```

---

### 🧪 Tip

For autocompound flows, the validator address can be **automatically resolved** if tokens are staked.  
If not, insert it manually or fetch via wallet's staking info.


---

## 📤 Stream Flow Example

**Label:** `Stream 1 ATOM`  
[Open on Intento Portal](https://portal.intento.zone/build?flowInput=%7B%22duration%22%3A857%2C%22interval%22%3A86400000%2C%22msgs%22%3A%5B%22%7B%5Cn++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.authz.v1beta1.MsgExec%5C%22%2C%5Cn++%5C%22value%5C%22%3A+%7B%5Cn++++%5C%22grantee%5C%22%3A+%5C%22cosmos1f50df80gh42aj9yyk47cxr6ze9tynjfdedc888syc370syflkcqs940wfn%5C%22%2C%5Cn++++%5C%22msgs%5C%22%3A+%5B%5Cn++++++%7B%5Cn++++++++%5C%22typeUrl%5C%22%3A+%5C%22%2Fcosmos.bank.v1beta1.MsgSend%5C%22%2C%5Cn++++++++%5C%22value%5C%22%3A+%7B%5Cn++++++++++%5C%22fromAddress%5C%22%3A+%5C%22cosmos1l0u08w8hj9srdc2n3gdmurs2ff5a97pu273vrq%5C%22%2C%5Cn++++++++++%5C%22toAddress%5C%22%3A+%5C%22cosmos1l0u08w8hj9srdc2n3gdmurs2ff5a97pu273vrq%5C%22%2C%5Cn++++++++++%5C%22amount%5C%22%3A+%5B%5Cn++++++++++++%7B%5Cn++++++++++++++%5C%22denom%5C%22%3A+%5C%22uatom%5C%22%2C%5Cn++++++++++++++%5C%22amount%5C%22%3A+%5C%221000000%5C%22%5Cn++++++++++++%7D%5Cn++++++++++%5D%5Cn++++++++%7D%5Cn++++++%7D%5Cn++++%5D%5Cn++%7D%5Cn%7D%22%5D%2C%22conditions%22%3A%7B%22feedbackLoops%22%3A%5B%5D%2C%22comparisons%22%3A%5B%5D%2C%22stopOnSuccessOf%22%3A%5B%5D%2C%22stopOnFailureOf%22%3A%5B%5D%2C%22skipOnFailureOf%22%3A%5B%5D%2C%22skipOnSuccessOf%22%3A%5B%5D%2C%22useAndForComparisons%22%3Afalse%7D%2C%22configuration%22%3A%7B%22saveResponses%22%3Atrue%2C%22updatingDisabled%22%3Afalse%2C%22stopOnSuccess%22%3Afalse%2C%22stopOnFailure%22%3Afalse%2C%22stopOnTimeout%22%3Afalse%2C%22walletFallback%22%3Atrue%7D%2C%22connectionId%22%3A%22%22%2C%22trustlessAgent%22%3A%7B%22agentAddress%22%3A%22into154sh4gcax7eyu9pw389gy8pngx07ll30z44d84rh742xxlhv4f5sr68jlv%22%2C%22feeLimit%22%3A%5B%7B%22denom%22%3A%22uinto%22%2C%22amount%22%3A%2220000%22%7D%5D%2C%22connectionId%22%3A%22connection-0%22%7D%2C%22label%22%3A%22Stream+1+ATOM%22%2C%22chainId%22%3A%22cosmoshub-4%22%7D)

### 🔁 Automation
- Executes every 24 hours.
- Sends a fixed amount of 1 ATOM from a Cosmos address to itself — used to simulate or test a **streaming payment** model.

---

### 🧾 Message Executed

```json
{
  "typeUrl": "/cosmos.authz.v1beta1.MsgExec",
  "value": {
    "grantee": "into154sh4gcax7eyu9pw389gy8pngx07ll30z44d84rh742xxlhv4f5sr68jlv",
    "msgs": [
      {
        "typeUrl": "/cosmos.bank.v1beta1.MsgSend",
        "value": {
          "fromAddress": "Your cosmos address",
          "toAddress": "Your cosmos address",
          "amount": [
            {
              "denom": "uatom",
              "amount": "1000000"
            }
          ]
        }
      }
    ]
  }
}
```

---

### ⚙️ Agent + Config

```json
{
  "trustlessAgent": {
    "agentAddress": "into154sh4gcax7eyu9pw389gy8pngx07ll30z44d84rh742xxlhv4f5sr68jlv",
    "connectionId": "connection-0",
    "feeLimit": [
      {
        "denom": "uinto",
        "amount": "20000"
      }
    ]
  },
  "configuration": {
    "saveResponses": true,
    "updatingDisabled": false,
    "stopOnSuccess": true,
    "stopOnFailure": false,
    "stopOnTimeout": true,
    "walletFallback": true
  },
}
```

---

### 🧠 Notes

- This type of automation is ideal for **streaming payouts**, **salary disbursement**, or **gradual fund release** scenarios.
- You can change `toAddress` to any desired recipient and adjust the `amount` for flexible streaming.

