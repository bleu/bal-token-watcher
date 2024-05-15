import { ponder } from "@/generated";
import { VaultAbi } from "../abis/VaultAbi";
import { erc20Abi } from "viem";

ponder.on("Vault:Swap", async ({ event, context }) => {
  const { swaps } = context.db;

  await Promise.all(
    [event.args.tokenIn, event.args.tokenOut].map(async (token) => {
      const canonicalId = `${token}-${context.network.name}`;
      const tokenData = await context.db.tokens.findUnique({
        id: canonicalId,
      });

      if (tokenData) return;

      const contract = { abi: erc20Abi, address: token };
      const [tokenName, tokenSymbol, tokenDecimals] =
        await context.client.multicall({
          contracts: [
            {
              ...contract,
              functionName: "name",
            },
            {
              ...contract,
              functionName: "symbol",
            },
            {
              ...contract,
              functionName: "decimals",
            },
          ],
        });

      if (
        !(
          tokenName.status == "success" &&
          tokenSymbol.status == "success" &&
          tokenDecimals.status == "success"
        )
      ) {
        return;
      }

      return context.db.tokens.create({
        id: canonicalId,
        data: {
          address: token,
          name: String(tokenName.result),
          symbol: String(tokenSymbol.result),
          decimals: Number(tokenDecimals.result),
          chainId: context.network.chainId,
        },
      });
    })
  );

  await swaps.create({
    id: event.log.id,
    data: {
      tokenIn: event.args.tokenIn,
      tokenOut: event.args.tokenOut,
      poolId: event.args.poolId,
      amountIn: event.args.amountIn,
      amountOut: event.args.amountOut,
      chainId: context.network.chainId,
    },
  });
});
