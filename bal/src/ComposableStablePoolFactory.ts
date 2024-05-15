import { ponder } from "@/generated";

ponder.on(
  "ComposableStablePoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ComposableStablePoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
