import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolV4Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolV4Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
