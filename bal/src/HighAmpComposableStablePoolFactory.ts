import { ponder } from "@/generated";

ponder.on(
  "HighAmpComposableStablePoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "HighAmpComposableStablePoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
