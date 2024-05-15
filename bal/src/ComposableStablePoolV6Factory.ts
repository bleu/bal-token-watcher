import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolV6Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolV6Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
