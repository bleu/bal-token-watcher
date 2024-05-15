import { ponder } from "@/generated";

ponder.on(
  "AaveLinearPoolV3Factory:AaveLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "AaveLinearPoolV3Factory:AaveLinearPoolProtocolIdRegistered",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "AaveLinearPoolV3Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("AaveLinearPoolV3Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
