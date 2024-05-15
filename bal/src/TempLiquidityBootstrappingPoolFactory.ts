import { ponder } from "@/generated";

ponder.on(
  "TempLiquidityBootstrappingPoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
