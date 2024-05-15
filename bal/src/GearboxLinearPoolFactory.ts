import { ponder } from "@/generated";

ponder.on(
  "GearboxLinearPoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "GearboxLinearPoolFactory:GearboxLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "GearboxLinearPoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
