import { ponder } from "@/generated";

ponder.on("FXPoolDeployer:ApproveBaseOracle", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on(
  "FXPoolDeployer:BaseAssimilatorTemplateSet",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on("FXPoolDeployer:DisapproveBaseOracle", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("FXPoolDeployer:FXPoolCollectorSet", async ({ event, context }) => {
  console.log(event.args);
});
