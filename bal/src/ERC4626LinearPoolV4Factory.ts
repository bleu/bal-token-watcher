import { ponder } from "@/generated";

ponder.on(
  "ERC4626LinearPoolV4Factory:Erc4626LinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ERC4626LinearPoolV4Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ERC4626LinearPoolV4Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
