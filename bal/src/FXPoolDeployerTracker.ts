import { ponder } from "@/generated";

ponder.on(
  "FXPoolDeployerTracker:NewFXPoolDeployer",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "FXPoolDeployerTracker:OwnershipTransferred",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
