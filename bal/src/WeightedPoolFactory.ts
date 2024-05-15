import { ponder } from "@/generated";

ponder.on("WeightedPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
