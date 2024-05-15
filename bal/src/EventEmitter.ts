import { ponder } from "@/generated";

ponder.on("EventEmitter:AuthorizationGranted", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("EventEmitter:AuthorizationRevoked", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("EventEmitter:LogArgument", async ({ event, context }) => {
  console.log(event.args);
});

ponder.on("EventEmitter:OwnershipTransferred", async ({ event, context }) => {
  console.log(event.args);
});
