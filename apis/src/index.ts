import { transfer } from "./db/schema/Listener";
import { db, App, middlewares } from "@duneanalytics/sim-idx";

const app = App.create();
app.use("*", middlewares.authentication);

const SIM_APIS_API_KEY = "sim_DYdWss9VirhTUEZHOlz1WIuOh2v9pMuL";

app.get("/*", async (c) => {
  try {
    const result = await db
      .client(c)
      .select()
      .from(transfer)
      .limit(5);

    function normalizeAddress(input: any): string | null {
      if (!input) return null;
      if (typeof input === "string") return input;
      // sim-idx address wrapper often as { address: Uint8Array }
      const bytes: any = (input as any).address ?? input;
      if (bytes && typeof bytes.length === "number") {
        let hex = "";
        for (let i = 0; i < bytes.length; i++) {
          const b = bytes[i] as number;
          hex += (b & 0xff).toString(16).padStart(2, "0");
        }
        return "0x" + hex;
      }
      try {
        return String(input);
      } catch {
        return null;
      }
    }

    const tokensNormalized = (result ?? [])
      .map((r: any) => normalizeAddress(r.token))
      .filter((v: any) => !!v) as string[];
    const uniqueTokenAddresses = Array.from(new Set(tokensNormalized));
    console.log("uniqueTokenAddresses", uniqueTokenAddresses.length, uniqueTokenAddresses.slice(0, 10));

    const chainId = 8453; // Base only
    const apiKey = SIM_APIS_API_KEY;
    console.log("token-info config", { chainId, apiKeyPresent: !!apiKey });

    // Respect 5 requests/second limit: only fetch at most 5 tokens per request
    const MAX_TOKENS = 5;
    const tokensToFetch = uniqueTokenAddresses.slice(0, MAX_TOKENS);
    if (uniqueTokenAddresses.length > MAX_TOKENS) {
      console.log("TokenInfo: limiting lookups", { total: uniqueTokenAddresses.length, using: tokensToFetch.length });
    }

    function fetchWithTimeout(url: string, init: RequestInit, timeoutMs: number): Promise<Response> {
      const controller = new AbortController();
      const id = setTimeout(() => controller.abort(), timeoutMs);
      return fetch(url, { ...init, signal: controller.signal }).finally(() => clearTimeout(id));
    }

    function sleep(ms: number): Promise<void> {
      return new Promise((resolve) => setTimeout(resolve, ms));
    }

    async function fetchTokenInfo(address: string): Promise<string | null> {
      try {
        if (!apiKey) {
          console.log("TokenInfo: missing API key");
          return null;
        }
        const MAX_RETRIES = 3;
        const TIMEOUT_MS = 2500;
        for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
          try {
            const url = `https://api.sim.dune.com/v1/evm/token-info/${address}?chain_ids=${chainId}`;
            console.log("TokenInfo: fetching", { address, attempt, url });
            const resp = await fetchWithTimeout(
              url,
              { headers: { "X-Sim-Api-Key": apiKey } },
              TIMEOUT_MS
            );
            if (!resp.ok) {
              const text = await resp.text().catch(() => "");
              console.log("TokenInfo: non-OK", { address, attempt, status: resp.status, body: text.slice(0, 200) });
              if (resp.status === 429 || resp.status === 503) {
                await sleep(300 * attempt);
                continue;
              }
              return null;
            }
            const data: any = await resp.json();
            const tokens = Array.isArray(data?.tokens) ? data.tokens : [];
            const tokenEntry = tokens.find((t: any) => Number(t?.chain_id) === chainId) ?? tokens[0] ?? null;
            console.log("TokenInfo: parsed", {
              address,
              attempt,
              tokensLen: tokens.length,
              picked: tokenEntry ? { chain_id: tokenEntry.chain_id, price_usd: tokenEntry.price_usd } : null,
            });
            const price = tokenEntry?.price_usd;
            return typeof price === "number" && Number.isFinite(price) ? String(price) : null;
          } catch (err) {
            console.log("TokenInfo: exception", { address, attempt, err: (err as Error)?.message });
            await sleep(200 * attempt);
          }
        }
        return null;
      } catch (e) {
        console.log("TokenInfo: exception", { address, err: (e as Error)?.message });
        return null;
      }
    }

    const tokenInfoEntries = await Promise.all(
      tokensToFetch.map(async (addr) => [addr, await fetchTokenInfo(addr)] as const)
    );
    const tokenToPrice = new Map<string, string | null>(tokenInfoEntries);
    const nonNullCount = Array.from(tokenToPrice.values()).filter((v) => v != null).length;
    console.log("TokenInfo: resolved", { total: tokenToPrice.size, nonNull: nonNullCount });

    const enriched = (result ?? []).map((row: any) => {
      const norm = normalizeAddress(row.token);
      return {
        ...row,
        tokenInfoPriceUsd: tokenToPrice.get(norm as string) ?? null,
      };
    });

    return Response.json({ result: enriched });
  } catch (e) {
    console.error("Database operation failed:", e);
    return Response.json({ error: (e as Error).message }, { status: 500 });
  }
});

export default app;
