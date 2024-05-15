import { ponder } from "@/generated";

ponder.on("WeightedPoolV4Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
