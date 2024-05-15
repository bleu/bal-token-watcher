import { ponder } from "@/generated";

ponder.on(
  "SiloLinearPoolV2Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("SiloLinearPoolV2Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on(
  "SiloLinearPoolV2Factory:SiloLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
