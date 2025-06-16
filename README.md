![image](https://github.com/user-attachments/assets/0bd44452-5979-46d6-a10a-e4f0419e3129)

# Intento Integration Hub

Welcome to the **Intento Integration Hub** — your starting point for exploring how to integrate with Intento.

This repository contains real-world integration examples and client scripts for working with Intento-powered flows across the interchain ecosystem. Whether you're building on Cosmos, EVM, or another stack, these examples are designed to be plug-and-play.

## ✨ What's Inside

Each folder in this repo represents an integration, which can include:

- 📁 Example scripts and demo URLS to sumbmit  Intento flows
- 📘 TypeScript code with typed client helpers
- 🔍 Usage notes and integration-specific considerations

| Integration | Description |
|-------------|-------------|
| `ai-agents` | Integration input for a knowledge base agent for intent-based flows — exploring autonomous orchestration. |
| `autocompound-dydx` | Early-stage workaround for auto-compounding DYDX rewards within current Interchain Account (ICA) dYdX allowlist constraints. |
| `autocompound-elys` | Documentation on how how auto-compounding and DCA strategies can be implemeneted on Elys using Intento flows. |
| `streamswap` | Initial prototype for DCA strategies into StreamSwap streams — enabling time-based strategies via Intento flows. |
| `tokenstream.fun` | Integration using Skip API and IBC hooks to demonstrate decentralized DCA strategies across chains. |


### General Flows

| Flow Name                                | Description                                                                                                 | Link                                                                                  |
|------------------------------------------|-------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Simple Recurring Transfer (AuthZ + ICA) | Sends recurring transfers using AuthZ over Interchain Accounts.                                             | [View Flow](https://portal.intento.zone/flows/60285)                                   |
| Recurring Transfer with Balance Check    | Uses Interchain Query (ICQ) to validate available balance before executing a recurring transfer.            | [View Flow](https://portal.intento.zone/flows/60283)                                   |
| Host Chain Autocompound (Cosmos Coins)   | Auto-compounds staking rewards directly on the host chain for Cosmos-based tokens.                          | [View Flow](https://portal.intento.zone/flows/60284)                                   |
| Conditional Autocompound                 | Auto-compounding with conditional logic — such as minimum threshold or timing constraints.                  | [View Flow](https://portal.intento.zone/flows/60286)                                   |

## Learn more

[Intento documentation](https://docs.intento.zone)

Other useful links

- [Intento Portal - one-stop tool for flows](https://portal.intento.zone/)
- [Block Explorer](https://explorer.intento.zone/)
- [Networks repository](https://github.com/trstlabs/networks)
- [IntentoJS NPM package](https://www.npmjs.com/package/intentojs)
- [Swagger LCD Endpoint](https://lcd.intento.zone/swagger/)
- [RPC endpoint](https://rpc.intento.zone/)

## 📮 Questions or Suggestions?

Reach out via [info@intento.zone](mailto:info@intento.zone) or [Discord](https://discord.gg/hsVf9sYyZW) for support, feature requests, or to explore deeper collaborations.

Made with ❤️ by the [Intento](https://intento.zone) team.
