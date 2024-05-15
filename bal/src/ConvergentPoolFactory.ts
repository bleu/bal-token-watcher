import { ponder } from "@/generated";

ponder.on("ConvergentPoolFactory:CCPoolCreated", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("ConvergentPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
