import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolV3Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolV3Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
