import { createConfig } from "@ponder/core";
import { http, createPublicClient, webSocket } from "viem";

import { VaultAbi } from "./abis/VaultAbi";

const PONDER_RPC_URL_1 =
  "https://maximum-soft-surf.quiknode.pro/72dbfa645e306fe262614054331d8f312b3fdea6/";

const PONDER_RPC_URL_8453 =
  "https://billowing-tame-shard.base-mainnet.quiknode.pro/3d5bf3a55845523c98c26c21ed852cf378e3fa55/";

const PONDER_RPC_URL_42161 =
  "https://blissful-ultra-pine.arbitrum-mainnet.quiknode.pro/3297fb83be36978d3b3806d28ccafaaa6099d72a/";

const PONDER_RPC_URL_100 =
  "https://orbital-small-valley.xdai.quiknode.pro/baaeb9db666a5b1cf7f0e400e94a860887821611/";
const PONDER_RPC_URL_10 =
  "https://broken-chaotic-sanctuary.optimism.quiknode.pro/90ba4ff850759f40520eccb643941121f32a1f7b/";
const PONDER_RPC_URL_137 =
  "https://cosmological-omniscient-pool.matic.quiknode.pro/1c96130f73102251e00aa6d972e1424ed2f031c6/";

const PONDER_RPC_URL_1101 =
  "https://side-alien-darkness.zkevm-mainnet.quiknode.pro/6f883c9b25c2a51669a2a9a9ca527bbf8adf3a5c/";

const latestBlockMainnet = await createPublicClient({
  transport: http(PONDER_RPC_URL_1),
}).getBlock();
const latestBlockArbitrum = await createPublicClient({
  transport: http(PONDER_RPC_URL_42161),
}).getBlock();
const latestBlockBase = await createPublicClient({
  transport: http(PONDER_RPC_URL_8453),
}).getBlock();
const latestBlockGnosis = await createPublicClient({
  transport: http(PONDER_RPC_URL_100),
}).getBlock();
const latestBlockOptimism = await createPublicClient({
  transport: http(PONDER_RPC_URL_10),
}).getBlock();
const latestBlockPolygon = await createPublicClient({
  transport: http(PONDER_RPC_URL_137),
}).getBlock();
const latestBlockZkevm = await createPublicClient({
  transport: http(PONDER_RPC_URL_1101),
}).getBlock();

export default createConfig({
  networks: {
    mainnet: {
      chainId: 1,
      transport: http(PONDER_RPC_URL_1),
    },
    arbitrum: {
      chainId: 42161,
      transport: http(PONDER_RPC_URL_42161),
    },
    // avalanche: {
    //   chainId: 43114,
    //   transport: http("https://api.avax.network/ext/bc/C/rpc"),
    // },
    base: {
      chainId: 8453,
      transport: http(PONDER_RPC_URL_8453),
    },
    // fantom: {
    //   chainId: 250,
    //   transport: http("https://rpc.ftm.tools"),
    // },
    gnosis: {
      chainId: 100,
      transport: http(PONDER_RPC_URL_100),
    },
    optimism: {
      chainId: 10,
      transport: http(PONDER_RPC_URL_10),
    },
    polygon: {
      chainId: 137,
      transport: http(PONDER_RPC_URL_137),
    },
    zkevm: {
      chainId: 1101,
      transport: http(PONDER_RPC_URL_1101),
    },
  },
  contracts: {
    Vault: {
      abi: VaultAbi,
      filter: { event: "Swap" },
      address: "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
      network: {
        mainnet: {
          startBlock: Number(latestBlockMainnet.number) - 1000,
        },
        arbitrum: {
          startBlock: Number(latestBlockArbitrum.number) - 1000,
        },
        base: {
          startBlock: Number(latestBlockBase.number) - 1000,
        },
        gnosis: {
          startBlock: Number(latestBlockGnosis.number) - 1000,
        },
        optimism: {
          startBlock: Number(latestBlockOptimism.number) - 1000,
        },
        polygon: {
          startBlock: Number(latestBlockPolygon.number) - 1000,
        },
        zkevm: {
          startBlock: Number(latestBlockZkevm.number) - 1000,
        },
      },
    },
  },
});
