import { ponder } from "@/generated";

ponder.on(
  "ManagedPoolV2Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("ManagedPoolV2Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
