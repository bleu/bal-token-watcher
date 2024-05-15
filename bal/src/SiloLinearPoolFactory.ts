import { ponder } from "@/generated";

ponder.on(
  "SiloLinearPoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("SiloLinearPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on(
  "SiloLinearPoolFactory:SiloLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
