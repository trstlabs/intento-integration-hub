# 📄 StreamSwap FlowInput URL Guide

This guide shows how to **dynamically create a `flowInput` URL** for a DCA subscription using StreamSwap. You'll dynamically fill in:

* `amount`
* `denom`
* `stream_id`
* `label` (optional)

Everything else can be pre-filled.

---

## 🔗 Example `flowInput` URL

The final URL looks like this:

```
https://<INTENTO_PORTAL_ENDPOINT>/submit?flowInput=<ENCODED_FLOW_INPUT>&imageUrl=<OPTIONAL_IMAGE>&chain=<CHAIN_ID>&bgColor=<COLOR>
```

Example:

```plaintext
https://portal.intento.zone/submit?flowInput=<...>&imageUrl=https://portal.intento.zone/assets/logo-dark-CyJKup0l.png&chain=osmo-test-5&bgColor=#140739
```

The page can be [customized](https://docs.intento.zone/module/submit-page) with a custom image, background color, and more.

---

## 🧰 TypeScript Helper

Here’s a **TypeScript function** to build and encode the `flowInput`:

```ts
function buildFlowInputUrl({
  streamId,
  amount,
  denom,
  label = "DCA via StreamSwap 🚀"
}: {
  streamId: number;
  amount: string;
  denom: string;
  label?: string;
}): string {
  const flowInput = {
    duration: 0,
    msgs: [
      {
        typeUrl: "/cosmos.authz.v1beta1.MsgExec",
        value: {
          grantee: "ICA_ADDR", // will be replaced with the ICA address automatically
          msgs: [
            {
              typeUrl: "/cosmwasm.wasm.v1.MsgExecuteContract",
              value: {
                sender: "Your Address", // will be replaced with the user's Osmosis address automatically
                contract: "<STATIC_CONTRACT>",
                msg: {
                  subscribe: {
                    stream_id: streamId
                  }
                },
                funds: [
                  {
                    denom,
                    amount
                  }
                ]
              }
            }
          ]
        }
      }
    ],
    conditions: {
      feedbackLoops: [],
      comparisons: [],
      stopOnSuccessOf: [],
      stopOnFailureOf: [],
      skipOnFailureOf: [],
      skipOnSuccessOf: [],
      useAndForComparisons: false
    },
    configuration: {
      saveResponses: false,
      updatingDisabled: false,
      stopOnSuccess: false,
      stopOnFailure: false,
      stopOnTimeout: false,
      fallbackToOwnerBalance: true
    },
    hostedIcaConfig: {
      hostedAddress: "<STATIC_HOSTED_ICA>",//into-prefixed address
      feeCoinLimit: {
        denom: "uinto",
        amount: "50"// Limits the gas fees per gas unit for the hosted ICA
      }
    },
    label
  };

  const encoded = encodeURIComponent(JSON.stringify(flowInput));
  return `https://portal.intento.zone/submit?flowInput=${encoded}&imageUrl=https://portal.intento.zone/assets/logo-dark-CyJKup0l.png&chain=osmo-test-5&bgColor=#140739`;
}
```

### Final Notes

For a working example of a fully-formed Intento Flow with a hosted ICA on the Osmosis testnet, MsgExec wrapping, a `stream_id`, and `denom`, check this link:

👉 [Example Flow on Intento Portal Submit Page](https://portal.intento.zone/submit?flowInput={
  "duration": 900000,
  "interval": 300000,
  "msgs":["{\n  \"typeUrl\": \"/cosmos.authz.v1beta1.MsgExec\",\n  \"value\": {\n    \"grantee\": \"osmo1vca5pkkdgt42hj5mjkclqqfla9dgkrhdjeyq3am8a69s4a774nzqvgsjpn\",\n    \"msgs\": [\n      {\n        \"typeUrl\": \"/cosmwasm.wasm.v1.MsgExecuteContract\",\n        \"value\": {\n          \"sender\": \"Your Address\",\n          \"contract\": \"osmo10wn49z4ncskjnmf8mq95uyfkj9kkveqx9jvxylccjs2w5lw4k6gsy4cj9l\",\n          \"msg\": {\n            \"subscribe\": {\n              \"stream_id\": 47\n            }\n          },\n          \"funds\": [\n            {\n              \"denom\": \"factory/osmo1nz7qdp7eg30sr959wvrwn9j9370h4xt6ttm0h3/ussosmo\",\n              \"amount\": \"100\"\n            }\n          ]\n        }\n      }\n    ]\n  }\n}"],
  "configuration": {
    "saveResponses": true,
    "updatingDisabled": false,
    "stopOnSuccess": false,
    "stopOnFailure": false,
    "stopOnTimeout": false,
    "fallbackToOwnerBalance": true
  },
  "connectionId": "connection-2",
  "hostedIcaConfig": {
    "hostedAddress": "into1p9ccttjgzh5wlewm5s55qk73j9ccjt27x00tada89sfq5t9v69rsex0977",
    "feeCoinLimit": {
      "denom": "ibc/92E0120F15D037353CFB73C14651FC8930ADC05B93100FD7754D3A689E53B333",
      "amount": "50000"
    }
  },
  "label": "♾️ DCA into StreamSwap stream"
}&imageUrl=https://testnet.streamswap.io/assets/logo-dark-CyJKup0l.png&chain=osmo-test-5&bgColor=#140739)

