import { ponder } from "@/generated";

ponder.on(
  "ERC4626LinearPoolV3Factory:Erc4626LinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ERC4626LinearPoolV3Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ERC4626LinearPoolV3Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
