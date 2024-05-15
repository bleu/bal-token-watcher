export const FXPoolDeployerAbi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "oracleAddress",
        type: "address",
      },
    ],
    name: "ApproveBaseOracle",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "assimilatorAddress",
        type: "address",
      },
    ],
    name: "BaseAssimilatorTemplateSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "oracleAddress",
        type: "address",
      },
    ],
    name: "DisapproveBaseOracle",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "collectorAddress",
        type: "address",
      },
    ],
    name: "FXPoolCollectorSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "ownerAddress",
        type: "address",
      },
    ],
    name: "FXPoolOwnerSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "assimilatorAddress",
        type: "address",
      },
    ],
    name: "NewBaseAssimilator",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "id",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "fxpool",
        type: "address",
      },
    ],
    name: "NewFXPool",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "assimilatorAddress",
        type: "address",
      },
    ],
    name: "QuoteAssimilatorSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "caller",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "minProtocolPercentFee",
        type: "uint256",
      },
    ],
    name: "SetMinProtocolPercentFee",
    type: "event",
  },
  {
    inputs: [],
    name: "BASE_WEIGHT",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "LP_MINTED_ROUNDING_ERR_THRESHOLD",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "MIN_PERCENT_FEE",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "QUOTE_WEIGHT",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_baseOracle",
        type: "address",
      },
    ],
    name: "adminApproveBaseOracle",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_baseOracle",
        type: "address",
      },
    ],
    name: "adminDisapproveBaseOracle",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_a",
        type: "address",
      },
    ],
    name: "adminSetFxpoolCollector",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_a",
        type: "address",
      },
    ],
    name: "adminSetFxpoolOwner",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_minPercentProtocolFee",
        type: "uint256",
      },
    ],
    name: "adminSetMinProtocolPercentFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_quoteAssim",
        type: "address",
      },
    ],
    name: "adminSetQuoteAssimilator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_baseAssim",
        type: "address",
      },
    ],
    name: "adminSetbaseAssimilatorTemplate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "baseAssimilatorTemplate",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    name: "baseAssimilators",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "baseOraclesWhitelist",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "fxpoolCollector",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "fxpoolOwner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_fxpoolAddr",
        type: "address",
      },
    ],
    name: "getFXPoolDetails",
    outputs: [
      {
        internalType: "string",
        name: "name",
        type: "string",
      },
      {
        internalType: "address",
        name: "baseToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "baseOracle",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "protocolPercentFee",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "liquidity",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "alpha",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "beta",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "delta",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "epsilon",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "lambda",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_vault",
        type: "address",
      },
      {
        internalType: "address",
        name: "_quoteToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "_quoteAssimilator",
        type: "address",
      },
      {
        internalType: "address",
        name: "_baseAssimilatorTemplate",
        type: "address",
      },
    ],
    name: "initialize",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_baseToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "_baseOracle",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_initialDepositInNumeraire",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "_params",
        type: "bytes",
      },
    ],
    name: "newFXPool",
    outputs: [
      {
        internalType: "bytes32",
        name: "balancerPoolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "fxpoolAddr",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "poolsData",
    outputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "poolAddress",
        type: "address",
      },
      {
        internalType: "address",
        name: "baseAssimilatorTemplate",
        type: "address",
      },
      {
        internalType: "bool",
        name: "exists",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "quoteAssimilator",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "quoteToken",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "vault",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_initialDepositInNumeraire",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "_baseToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "_baseOracle",
        type: "address",
      },
    ],
    name: "viewDepositNoLiquidity",
    outputs: [
      {
        internalType: "uint256",
        name: "expectedShares",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "baseTokenAmount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "quoteTokenAmount",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;
