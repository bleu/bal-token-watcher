import { ponder } from "@/generated";

ponder.on("StablePoolV2Factory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
