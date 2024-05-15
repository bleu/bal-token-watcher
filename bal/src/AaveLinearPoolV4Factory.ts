import { ponder } from "@/generated";

ponder.on(
  "AaveLinearPoolV4Factory:AaveLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "AaveLinearPoolV4Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("AaveLinearPoolV4Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
