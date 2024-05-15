import { ponder } from "@/generated";

ponder.on(
  "WeightedPool2TokenFactory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
