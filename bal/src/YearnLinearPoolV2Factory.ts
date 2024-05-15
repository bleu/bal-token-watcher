import { ponder } from "@/generated";

ponder.on(
  "YearnLinearPoolV2Factory:FactoryDisabled",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "YearnLinearPoolV2Factory:PoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "YearnLinearPoolV2Factory:YearnLinearPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
