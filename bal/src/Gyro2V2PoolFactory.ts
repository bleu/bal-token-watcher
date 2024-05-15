import { ponder } from "@/generated";

ponder.on("Gyro2V2PoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
