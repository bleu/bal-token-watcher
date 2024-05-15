import { createSchema } from "@ponder/core";
import { table } from "console";

export default createSchema((p) => ({
  tokens: p.createTable({
    id: p.string(),
    name: p.string(),
    address: p.hex(),
    symbol: p.string(),
    decimals: p.int(),
    chainId: p.int(),
  }),

  swaps: p.createTable({
    id: p.string(),
    tokenIn: p.hex(),
    tokenOut: p.hex(),
    poolId: p.hex(),
    amountIn: p.bigint(),
    amountOut: p.bigint(),
    chainId: p.int(),
  }),
}));
