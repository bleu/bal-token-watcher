import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolV5Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolV5Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
