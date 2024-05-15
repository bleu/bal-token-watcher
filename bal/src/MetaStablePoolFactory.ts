import { ponder } from "@/generated";

ponder.on("MetaStablePoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
