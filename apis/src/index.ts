import { transfer } from "./db/schema/Listener"; // Adjust the import path as necessary
import { types, db, App, middlewares } from "@duneanalytics/sim-idx"; // Import schema to ensure it's registered

const app = App.create();
app.use("*", middlewares.authentication);

const SIM_APIS_API_KEY = `sim_38yrWlWCYc61syhCFdn1E5nWaY1vCVsr`;

app.get("/*", async (c) => {
  try {
    const result = await db
      .client(c)
      .select()
      .from(transfer)
      .limit(50);
    // Deduplicate token addresses
    const uniqueTokenAddresses = Array.from(
      new Set((result ?? []).map((r: any) => r.token).filter(Boolean))
    ) as string[];

    // Base chain id only
    const chainId = 8453;

    // Helper to fetch token info (price_usd, decimals)
    async function fetchTokenInfo(address: string): Promise<{ priceUsd: number | null; decimals: number | null }> {
      try {
        const resp = await fetch(
          `https://api.sim.dune.com/v1/evm/token-info/${address}?chain_ids=${chainId}`,
          {
            headers: {
              "X-Sim-Api-Key": SIM_APIS_API_KEY,
            },
          }
        );
        if (!resp.ok) return { priceUsd: null, decimals: null };
        const data: any = await resp.json();
        const tokenEntry = Array.isArray(data?.tokens) && data.tokens.length > 0 ? data.tokens[0] : null;
        const priceUsd = typeof tokenEntry?.price_usd === "number" ? tokenEntry.price_usd : null;
        const decimals = typeof tokenEntry?.decimals === "number" ? tokenEntry.decimals : null;
        return { priceUsd, decimals };
      } catch (_) {
        return { priceUsd: null, decimals: null };
      }
    }

    // Fetch in parallel for all unique tokens
    const tokenInfoEntries = await Promise.all(
      uniqueTokenAddresses.map(async (addr) => [addr, await fetchTokenInfo(addr)] as const)
    );
    const tokenToInfo = new Map<string, { priceUsd: number | null; decimals: number | null }>(tokenInfoEntries);

    function toBigInt(val: unknown): bigint {
      if (typeof val === "bigint") return val;
      if (typeof val === "string") return BigInt(val);
      if (typeof val === "number") return BigInt(Math.trunc(val));
      return 0n;
    }

    function bigIntToDecimalString(value: bigint, decimals: number): string {
      if (decimals <= 0) return value.toString();
      const negative = value < 0n;
      const abs = negative ? -value : value;
      const base = 10n ** BigInt(decimals);
      const integerPart = abs / base;
      const fractionalPart = abs % base;
      const fractionalStr = fractionalPart.toString().padStart(decimals, "0").replace(/0+$/, "");
      return `${negative ? "-" : ""}${integerPart.toString()}${fractionalStr ? "." + fractionalStr : ""}`;
    }

    const enriched = (result ?? []).map((row: any) => {
      const info = tokenToInfo.get(row.token as string);
      if (!info || info.priceUsd == null || info.decimals == null) {
        return { ...row, usdcValueFromTokenInfo: null };
      }
      const valueBig = toBigInt(row.value);
      const amountStr = bigIntToDecimalString(valueBig, info.decimals);
      const amountNum = Number(amountStr);
      const usdcValueFromTokenInfo = Number.isFinite(amountNum) ? amountNum * info.priceUsd : null;
      return { ...row, usdcValueFromTokenInfo };
    });

    return Response.json({ result: enriched });
  } catch (e) {
    console.error("Database operation failed:", e);
    return Response.json({ error: (e as Error).message }, { status: 500 });
  }
});

export default app;
