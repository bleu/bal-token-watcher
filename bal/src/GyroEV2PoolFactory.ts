import { ponder } from "@/generated";

ponder.on("GyroEV2PoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
