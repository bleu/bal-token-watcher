import { ponder } from "@/generated";

ponder.on("InvestmentPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
