import { ponder } from "@/generated";

ponder.on(
  "ManagedKassandraPoolControllerFactory:KassandraPoolCreated",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ManagedKassandraPoolControllerFactory:KassandraPoolCreatedTokens",
  async ({ event, context }) => {
    console.log(event.args);
  },
);

ponder.on(
  "ManagedKassandraPoolControllerFactory:OwnershipTransferred",
  async ({ event, context }) => {
    console.log(event.args);
  },
);
