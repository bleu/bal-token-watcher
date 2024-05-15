import { ponder } from "@/generated";

ponder.on("StablePoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
