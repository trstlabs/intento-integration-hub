# 🤖 AI Agents — Intento Integration Hub

The `ai-agents` directory provides foundational tooling to support autonomous agents that interact with Cosmos-based blockchains. This includes aggregating chain metadata, IBC info, and message schemas — all designed to power AI or knowledge-based systems with context-aware blockchain interaction capabilities.

## 🧠 What’s This For?

These scripts help generate structured, machine-readable data about chains, assets, and message types — making it easier to build AI agents that can reason about blockchain actions like IBC transfers, swaps, staking, and more.

---

## 🛠 Setup & Usage

### 1. **Generate Chain Registry Data**

Aggregates Cosmos chain, asset, and IBC metadata into consolidated JSON files:

```bash
chmod +x generate_chain_registry.sh
./generate_chain_registry.sh
```

Generated files:
- `../chain_info_testnets.json` – Chain info including testnets
- `../chain_info_mainnets.json` – Chain info excluding testnets
- `../asset_list_testnets.json` – Assets list for testnets
- `../asset_list_mainnets.json` – Assets list excluding testnets
- `../ibc_info.json` – IBC connections & paths
- `../ibc_ics20_memo_hooks.json` – ICS20 hooks & memo-capable contracts

---

### 2. **Generate Msg Schemas**

This generates TypeScript schemas and an `index.ts` file for Cosmos SDK and CosmWasm message types, useful for AI agents that need to construct valid transactions.

```bash
chmod +x generate-schema.sh
./generate-schema.sh
```

Output:
- `./schemas/msgs/` – Directory containing individual message schemas and `index.ts`

---

### 3. **Aggregate Schemas by Type**

Groups schemas by project type for easier semantic lookup in AI/LLM-based systems.

```bash
chmod +x aggregate_schema.sh
./aggregate_schema.sh
```

Output:
- Organized schemas by chain or platform: `osmosis`, `elys`, `intento`, `cosmos`, `cosmwasm`, etc.

---

### 4. **Fetch Osmosis Pools**

Fetches pool data from Osmosis to assist with swap planning or simulation and make a JSON file:

```bash
chmod +x fetch_osmosis_pools.sh
./fetch_osmosis_pools.sh
```

Ofcourse, the `fetch_osmosis_pools.sh` script can be modified to fetch data from other chains, and an API integration can be added to the agent to fetch the data directly. 


## 🧬 Next Steps

This setup is ideal for:
- Building AI agents that reason about interchain flows
- Knowledge bases that need chain & tx context
- Developer tools that autogenerate UI or SDK logic based on schemas

Stay tuned for live agent demos built with this data ✨
