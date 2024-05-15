import { ponder } from "@/generated";

ponder.on("AaveLinearPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
