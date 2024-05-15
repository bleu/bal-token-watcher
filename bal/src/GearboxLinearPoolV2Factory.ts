import { ponder } from "@/generated";

ponder.on(
  "GearboxLinearPoolV2Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "GearboxLinearPoolV2Factory:GearboxLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "GearboxLinearPoolV2Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
