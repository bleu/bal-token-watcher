import { ponder } from "@/generated";

ponder.on(
  "AaveLinearPoolV5Factory:AaveLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "AaveLinearPoolV5Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("AaveLinearPoolV5Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
