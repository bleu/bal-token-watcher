import { ponder } from "@/generated";

ponder.on(
  "LiquidityBootstrappingPoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
