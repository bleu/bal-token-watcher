import { ponder } from "@/generated";

ponder.on(
  "StablePhantomPoolFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
