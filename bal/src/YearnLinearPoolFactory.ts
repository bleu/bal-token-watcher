import { ponder } from "@/generated";

ponder.on(
  "YearnLinearPoolFactory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("YearnLinearPoolFactory:PoolCreated", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on(
  "YearnLinearPoolFactory:YearnLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
