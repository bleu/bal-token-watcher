import { createConfig } from "@ponder/core";
import { http } from "viem";

import { EventEmitterAbi } from "./abis/EventEmitterAbi";
import { VaultAbi } from "./abis/VaultAbi";
import { WeightedPoolFactoryAbi } from "./abis/WeightedPoolFactoryAbi";
import { StablePoolFactoryAbi } from "./abis/StablePoolFactoryAbi";
import { MetaStablePoolFactoryAbi } from "./abis/MetaStablePoolFactoryAbi";
import { LiquidityBootstrappingPoolFactoryAbi } from "./abis/LiquidityBootstrappingPoolFactoryAbi";
import { InvestmentPoolFactoryAbi } from "./abis/InvestmentPoolFactoryAbi";
import { ManagedPoolV2FactoryAbi } from "./abis/ManagedPoolV2FactoryAbi";
import { ManagedKassandraPoolControllerFactoryAbi } from "./abis/ManagedKassandraPoolControllerFactoryAbi";
import { ConvergentPoolFactoryAbi } from "./abis/ConvergentPoolFactoryAbi";
import { StablePhantomPoolFactoryAbi } from "./abis/StablePhantomPoolFactoryAbi";
import { ComposableStablePoolFactoryAbi } from "./abis/ComposableStablePoolFactoryAbi";
import { ComposableStablePoolV2FactoryAbi } from "./abis/ComposableStablePoolV2FactoryAbi";
import { AaveLinearPoolFactoryAbi } from "./abis/AaveLinearPoolFactoryAbi";
import { AaveLinearPoolV3FactoryAbi } from "./abis/AaveLinearPoolV3FactoryAbi";
import { AaveLinearPoolV4FactoryAbi } from "./abis/AaveLinearPoolV4FactoryAbi";
import { AaveLinearPoolV5FactoryAbi } from "./abis/AaveLinearPoolV5FactoryAbi";
import { EulerLinearPoolFactoryAbi } from "./abis/EulerLinearPoolFactoryAbi";
import { ERC4626LinearPoolFactoryAbi } from "./abis/ERC4626LinearPoolFactoryAbi";
import { ERC4626LinearPoolV3FactoryAbi } from "./abis/ERC4626LinearPoolV3FactoryAbi";
import { ERC4626LinearPoolV4FactoryAbi } from "./abis/ERC4626LinearPoolV4FactoryAbi";
import { GearboxLinearPoolFactoryAbi } from "./abis/GearboxLinearPoolFactoryAbi";
import { GearboxLinearPoolV2FactoryAbi } from "./abis/GearboxLinearPoolV2FactoryAbi";
import { SiloLinearPoolFactoryAbi } from "./abis/SiloLinearPoolFactoryAbi";
import { SiloLinearPoolV2FactoryAbi } from "./abis/SiloLinearPoolV2FactoryAbi";
import { YearnLinearPoolFactoryAbi } from "./abis/YearnLinearPoolFactoryAbi";
import { YearnLinearPoolV2FactoryAbi } from "./abis/YearnLinearPoolV2FactoryAbi";
import { Gyro2V2PoolFactoryAbi } from "./abis/Gyro2V2PoolFactoryAbi";
import { GyroEV2PoolFactoryAbi } from "./abis/GyroEV2PoolFactoryAbi";
import { FXPoolFactoryAbi } from "./abis/FXPoolFactoryAbi";
import { FXPoolDeployerTrackerAbi } from "./abis/FXPoolDeployerTrackerAbi";
import { FXPoolDeployerAbi } from "./abis/FXPoolDeployerAbi";
import { ProtocolIdRegistryAbi } from "./abis/ProtocolIdRegistryAbi";

export default createConfig({
  networks: {
    mainnet: { chainId: 1, transport: http(process.env.PONDER_RPC_URL_1) },
  },
  contracts: {
    EventEmitter: {
      network: "mainnet",
      address: "0x1ACfEEA57d2ac674d7E65964f155AB9348A6C290",
      abi: EventEmitterAbi,
      startBlock: 16419620,
    },
    Vault: {
      network: "mainnet",
      address: "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
      abi: VaultAbi,
      startBlock: 12272146,
    },
    WeightedPoolFactory: {
      network: "mainnet",
      address: "0x8E9aa87E45e92bad84D5F8DD1bff34Fb92637dE9",
      abi: WeightedPoolFactoryAbi,
      startBlock: 12272146,
    },
    WeightedPoolV2Factory: {
      network: "mainnet",
      address: "0xcC508a455F5b0073973107Db6a878DdBDab957bC",
      abi: WeightedPoolFactoryAbi,
      startBlock: 15497271,
    },
    WeightedPoolV3Factory: {
      network: "mainnet",
      address: "0x5Dd94Da3644DDD055fcf6B3E1aa310Bb7801EB8b",
      abi: WeightedPoolFactoryAbi,
      startBlock: 16520627,
    },
    WeightedPoolV4Factory: {
      network: "mainnet",
      address: "0x897888115Ada5773E02aA29F775430BFB5F34c51",
      abi: WeightedPoolFactoryAbi,
      startBlock: 16878323,
    },
    WeightedPool2TokenFactory: {
      network: "mainnet",
      address: "0xA5bf2ddF098bb0Ef6d120C98217dD6B141c74EE0",
      abi: WeightedPoolFactoryAbi,
      startBlock: 12272146,
    },
    StablePoolFactory: {
      network: "mainnet",
      address: "0xc66Ba2B6595D3613CCab350C886aCE23866EDe24",
      abi: StablePoolFactoryAbi,
      startBlock: 12703127,
    },
    StablePoolV2Factory: {
      network: "mainnet",
      address: "0x8df6EfEc5547e31B0eb7d1291B511FF8a2bf987c",
      abi: StablePoolFactoryAbi,
      startBlock: 14934936,
    },
    MetaStablePoolFactory: {
      network: "mainnet",
      address: "0x67d27634E44793fE63c467035E31ea8635117cd4",
      abi: MetaStablePoolFactoryAbi,
      startBlock: 13011941,
    },
    LiquidityBootstrappingPoolFactory: {
      network: "mainnet",
      address: "0x751A0bC0e3f75b38e01Cf25bFCE7fF36DE1C87DE",
      abi: LiquidityBootstrappingPoolFactoryAbi,
      startBlock: 12871780,
    },
    TempLiquidityBootstrappingPoolFactory: {
      network: "mainnet",
      address: "0x0F3e0c4218b7b0108a3643cFe9D3ec0d4F57c54e",
      abi: LiquidityBootstrappingPoolFactoryAbi,
      startBlock: 13730248,
    },
    InvestmentPoolFactory: {
      network: "mainnet",
      address: "0x48767F9F868a4A7b86A90736632F6E44C2df7fa9",
      abi: InvestmentPoolFactoryAbi,
      startBlock: 13279079,
    },
    ManagedPoolV2Factory: {
      network: "mainnet",
      address: "0xBF904F9F340745B4f0c4702c7B6Ab1e808eA6b93",
      abi: ManagedPoolV2FactoryAbi,
      startBlock: 17046230,
    },
    ManagedKassandraPoolControllerFactory: {
      network: "mainnet",
      address: "0x0000000000000000000000000000000000000000",
      abi: ManagedKassandraPoolControllerFactoryAbi,
      startBlock: 17046230,
    },
    ConvergentPoolFactory: {
      network: "mainnet",
      address: "0xb7561f547F3207eDb42A6AfA42170Cd47ADD17BD",
      abi: ConvergentPoolFactoryAbi,
      startBlock: 12686198,
    },
    StablePhantomPoolFactory: {
      network: "mainnet",
      address: "0xb08E16cFc07C684dAA2f93C70323BAdb2A6CBFd2",
      abi: StablePhantomPoolFactoryAbi,
      startBlock: 13766527,
    },
    ComposableStablePoolFactory: {
      network: "mainnet",
      address: "0xf9ac7B9dF2b3454E841110CcE5550bD5AC6f875F",
      abi: ComposableStablePoolFactoryAbi,
      startBlock: 15485885,
    },
    ComposableStablePoolV2Factory: {
      network: "mainnet",
      address: "0x85a80afee867aDf27B50BdB7b76DA70f1E853062",
      abi: ComposableStablePoolV2FactoryAbi,
      startBlock: 16083775,
    },
    ComposableStablePoolV3Factory: {
      network: "mainnet",
      address: "0xdba127fBc23fb20F5929C546af220A991b5C6e01",
      abi: ComposableStablePoolV2FactoryAbi,
      startBlock: 16520627,
    },
    ComposableStablePoolV4Factory: {
      network: "mainnet",
      address: "0xfADa0f4547AB2de89D1304A668C39B3E09Aa7c76",
      abi: ComposableStablePoolV2FactoryAbi,
      startBlock: 16878679,
    },
    ComposableStablePoolV5Factory: {
      network: "mainnet",
      address: "0xDB8d758BCb971e482B2C45f7F8a7740283A1bd3A",
      abi: ComposableStablePoolV2FactoryAbi,
      startBlock: 17643198,
    },
    ComposableStablePoolV6Factory: {
      network: "mainnet",
      address: "0x5B42eC6D40f7B7965BE5308c70e2603c0281C1E9",
      abi: ComposableStablePoolV2FactoryAbi,
      startBlock: 19314764,
    },
    HighAmpComposableStablePoolFactory: {
      network: "mainnet",
      address: "0xBa1b4a90bAD57470a2cbA762A32955dC491f76e0",
      abi: ComposableStablePoolFactoryAbi,
      startBlock: 15852258,
    },
    AaveLinearPoolFactory: {
      network: "mainnet",
      address: "0xD7FAD3bd59D6477cbe1BE7f646F7f1BA25b230f8",
      abi: AaveLinearPoolFactoryAbi,
      startBlock: 13766443,
    },
    AaveLinearPoolV2Factory: {
      network: "mainnet",
      address: "0x6A0AC04f5C2A10297D5FA79FA6358837a8770041",
      abi: AaveLinearPoolFactoryAbi,
      startBlock: 15359085,
    },
    AaveLinearPoolV3Factory: {
      network: "mainnet",
      address: "0x7d833FEF5BB92ddb578DA85fc0c35cD5Cc00Fb3e",
      abi: AaveLinearPoolV3FactoryAbi,
      startBlock: 16136501,
    },
    AaveLinearPoolV4Factory: {
      network: "mainnet",
      address: "0xb9F8AB3ED3F3aCBa64Bc6cd2DcA74B7F38fD7B88",
      abi: AaveLinearPoolV4FactoryAbi,
      startBlock: 16600026,
    },
    AaveLinearPoolV5Factory: {
      network: "mainnet",
      address: "0x0b576c1245F479506e7C8bbc4dB4db07C1CD31F9",
      abi: AaveLinearPoolV5FactoryAbi,
      startBlock: 17045353,
    },
    EulerLinearPoolFactory: {
      network: "mainnet",
      address: "0x5F43FBa61f63Fa6bFF101a0A0458cEA917f6B347",
      abi: EulerLinearPoolFactoryAbi,
      startBlock: 16588077,
    },
    ERC4626LinearPoolFactory: {
      network: "mainnet",
      address: "0xE061bF85648e9FA7b59394668CfEef980aEc4c66",
      abi: ERC4626LinearPoolFactoryAbi,
      startBlock: 14521506,
    },
    ERC4626LinearPoolV3Factory: {
      network: "mainnet",
      address: "0x67A25ca2350Ebf4a0C475cA74C257C94a373b828",
      abi: ERC4626LinearPoolV3FactoryAbi,
      startBlock: 16542240,
    },
    ERC4626LinearPoolV4Factory: {
      network: "mainnet",
      address: "0x813EE7a840CE909E7Fea2117A44a90b8063bd4fd",
      abi: ERC4626LinearPoolV4FactoryAbi,
      startBlock: 17045391,
    },
    GearboxLinearPoolFactory: {
      network: "mainnet",
      address: "0x2EbE41E1aa44D61c206A94474932dADC7D3FD9E3",
      abi: GearboxLinearPoolFactoryAbi,
      startBlock: 16637919,
    },
    GearboxLinearPoolV2Factory: {
      network: "mainnet",
      address: "0x39A79EB449Fc05C92c39aA6f0e9BfaC03BE8dE5B",
      abi: GearboxLinearPoolV2FactoryAbi,
      startBlock: 17052583,
    },
    SiloLinearPoolFactory: {
      network: "mainnet",
      address: "0xfd1c0e6f02f71842b6ffF7CdC7A017eE1Fd3CdAC",
      abi: SiloLinearPoolFactoryAbi,
      startBlock: 16869467,
    },
    SiloLinearPoolV2Factory: {
      network: "mainnet",
      address: "0x4E11AEec21baF1660b1a46472963cB3DA7811C89",
      abi: SiloLinearPoolV2FactoryAbi,
      startBlock: 17052627,
    },
    YearnLinearPoolFactory: {
      network: "mainnet",
      address: "0x8b7854708c0C54f9D7d1FF351D4F84E6dE0E134C",
      abi: YearnLinearPoolFactoryAbi,
      startBlock: 16638024,
    },
    YearnLinearPoolV2Factory: {
      network: "mainnet",
      address: "0x5F5222Ffa40F2AEd6380D022184D6ea67C776eE0",
      abi: YearnLinearPoolV2FactoryAbi,
      startBlock: 17052602,
    },
    Gyro2V2PoolFactory: {
      network: "mainnet",
      address: "0x579653927BF509B361F6e3813f5D4B95331d98c9",
      abi: Gyro2V2PoolFactoryAbi,
      startBlock: 18577307,
    },
    GyroEV2PoolFactory: {
      network: "mainnet",
      address: "0x412a5B2e7a678471985542757A6855847D4931D5",
      abi: GyroEV2PoolFactoryAbi,
      startBlock: 17672894,
    },
    FXPoolFactory: {
      network: "mainnet",
      address: "0x81fE9e5B28dA92aE949b705DfDB225f7a7cc5134",
      abi: FXPoolFactoryAbi,
      startBlock: 15981805,
    },
    FXPoolDeployerTracker: {
      network: "mainnet",
      address: "0x9E0d068Ede387888f8A24c92F7486920c200EfD5",
      abi: FXPoolDeployerTrackerAbi,
      startBlock: 19417173,
    },
    FXPoolDeployer: {
      network: "mainnet",
      address: "0xfb23Bc0D2629268442CD6521CF4170698967105f",
      abi: FXPoolDeployerAbi,
      startBlock: 18469425,
    },
    ProtocolIdRegistry: {
      network: "mainnet",
      address: "0xc3ccacE87f6d3A81724075ADcb5ddd85a8A1bB68",
      abi: ProtocolIdRegistryAbi,
      startBlock: 16719996,
    },
  },
});
