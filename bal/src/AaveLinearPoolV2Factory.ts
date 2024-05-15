import { ponder } from "@/generated";

ponder.on("AaveLinearPoolV2Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
