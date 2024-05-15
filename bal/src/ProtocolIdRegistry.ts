import { ponder } from "@/generated";

ponder.on(
  "ProtocolIdRegistry:ProtocolIdRegistered",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ProtocolIdRegistry:ProtocolIdRenamed",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
