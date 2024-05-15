import { ponder } from "@/generated";

ponder.on("WeightedPoolV3Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
