import { ponder } from "@/generated";

ponder.on("WeightedPoolV2Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
