import { ponder } from "@/generated";

ponder.on(
  "ERC4626LinearPoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
