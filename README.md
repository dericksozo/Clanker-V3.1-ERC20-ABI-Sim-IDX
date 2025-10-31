# Retake.tv Clanker Token Indexer (Sim IDX)

**Sim IDX** is a framework for building and deploying apps that index onchain data and expose it via APIs. This app indexes Retake.tv-only **Clanker tokens** on Base (versions **V3.1** and **V4**) and provides a lightweight API to consume the data.

At a high level: the listener watches all ERC‑20 transfers on Base, filters down to Retake.tv Clanker tokens, computes each transfer’s WETH value using Uniswap V3 or V4 depending on token version, and converts that to a block‑time USD value using the canonical WETH/USDC Uniswap V3 pool. The API then enriches rows with the token’s current USD price using Sim APIs.

## What You'll Edit

The main files and folders you'll work with are:

-   **`abis/`** - Add JSON ABIs required by listeners (includes ERC‑20).
-   **`listeners/src/`** - `Main.sol` registers triggers; `ClankerTokenListener.sol` contains the filtering, pricing, and event emission.
-   **`apis/src/index.ts`** - API routes that query the indexed tables and enrich rows with current token USD price.

## How It Works

-   **Scope (Base):** Listens to all ERC‑20 `Transfer` logs, then filters to Retake.tv Clanker tokens using factory checks (V3.1/V4) and the token’s `context()` string.
-   **Price in WETH:** Uses Uniswap V4 Quoter for V4 tokens; for V3.1, discovers an initialized token/WETH pool (or falls back via USDC) and quotes with QuoterV2.
-   **USD at block‑time:** Converts WETH→USD using the canonical WETH/USDC Uniswap V3 pool’s current `slot0` price.
-   **Event → table:** Emits a `Transfer` event saved to `transfer` (addresses, amounts, WETH, USD, block info, version, side, context).

On the API side, `apis/src/index.ts` queries recent rows from `transfer` and enriches each row with the token’s **current** USD price (not historical) via Sim APIs (`/v1/evm/token-info`), returning a compact JSON payload for clients.

## App Structure

```text
.
├── sim.toml                     # App configuration
├── apis/                        # Hono + Drizzle API (Cloudflare Workers)
│   └── src/index.ts             # Enriches rows with current USD price via Sim APIs
├── abis/                        # Contract ABI files (JSON)
│   └── ERC20.json               # ERC‑20 ABI for log decoding
└── listeners/                   # Foundry project for listener contracts
    ├── src/
    │   ├── Main.sol             # Registers ERC‑20 Transfer trigger on Base
    │   └── ClankerTokenListener.sol # Filtering, pricing, USD conversion, event emit
    └── test/
        └── Main.t.sol           # Unit tests for the listener
```

The `listeners/` directory is a Foundry project where your indexing logic lives. For a full breakdown, see the [App Folder Structure](https://docs.sim.dune.com/idx/app-structure).

## Next Steps

Ready to iterate or deploy?

-   **[Deploying Your App](https://docs.sim.dune.com/idx/deployment)** - Ship to production or previews
-   **[Adding ABIs](https://docs.sim.dune.com/idx/cli#sim-abi)** - Register additional contracts
-   **[Writing Listeners](https://docs.sim.dune.com/idx/listener)** - Extend filtering/pricing logic
-   **[CLI Reference](https://docs.sim.dune.com/idx/cli)** - All available commands