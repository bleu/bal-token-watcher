import { ponder } from "@/generated";

ponder.on("FXPoolFactory:NewFXPool", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("FXPoolFactory:OwnershipTransferred", async ({ event, context }) => {
  console.log(event.args);
});
