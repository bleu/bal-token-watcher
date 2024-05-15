import { ponder } from "@/generated";

ponder.on("Vault:Swap", async ({ event, context }) => {
  console.log(event.args);
});
