import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolV2Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolV2Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
