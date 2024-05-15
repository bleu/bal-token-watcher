import { ponder } from "@/generated";

ponder.on(
  "EulerLinearPoolFactory:EulerLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "EulerLinearPoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("EulerLinearPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});
