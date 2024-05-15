export const GyroEV2PoolAbi = [
  {
    inputs: [
      {
        components: [
          {
            components: [
              {
                internalType: "contract IVault",
                name: "vault",
                type: "address",
              },
              {
                internalType: "string",
                name: "name",
                type: "string",
              },
              {
                internalType: "string",
                name: "symbol",
                type: "string",
              },
              {
                internalType: "contract IERC20",
                name: "token0",
                type: "address",
              },
              {
                internalType: "contract IERC20",
                name: "token1",
                type: "address",
              },
              {
                internalType: "uint256",
                name: "swapFeePercentage",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "pauseWindowDuration",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "bufferPeriodDuration",
                type: "uint256",
              },
              {
                internalType: "bool",
                name: "oracleEnabled",
                type: "bool",
              },
              {
                internalType: "address",
                name: "owner",
                type: "address",
              },
            ],
            internalType: "struct ExtensibleWeightedPool2Tokens.NewPoolParams",
            name: "baseParams",
            type: "tuple",
          },
          {
            components: [
              {
                internalType: "int256",
                name: "alpha",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "beta",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "c",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "s",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "lambda",
                type: "int256",
              },
            ],
            internalType: "struct GyroECLPMath.Params",
            name: "eclpParams",
            type: "tuple",
          },
          {
            components: [
              {
                components: [
                  {
                    internalType: "int256",
                    name: "x",
                    type: "int256",
                  },
                  {
                    internalType: "int256",
                    name: "y",
                    type: "int256",
                  },
                ],
                internalType: "struct GyroECLPMath.Vector2",
                name: "tauAlpha",
                type: "tuple",
              },
              {
                components: [
                  {
                    internalType: "int256",
                    name: "x",
                    type: "int256",
                  },
                  {
                    internalType: "int256",
                    name: "y",
                    type: "int256",
                  },
                ],
                internalType: "struct GyroECLPMath.Vector2",
                name: "tauBeta",
                type: "tuple",
              },
              {
                internalType: "int256",
                name: "u",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "v",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "w",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "z",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "dSq",
                type: "int256",
              },
            ],
            internalType: "struct GyroECLPMath.DerivedParams",
            name: "derivedEclpParams",
            type: "tuple",
          },
          {
            internalType: "address",
            name: "rateProvider0",
            type: "address",
          },
          {
            internalType: "address",
            name: "rateProvider1",
            type: "address",
          },
          {
            internalType: "address",
            name: "capManager",
            type: "address",
          },
          {
            components: [
              {
                internalType: "bool",
                name: "capEnabled",
                type: "bool",
              },
              {
                internalType: "uint120",
                name: "perAddressCap",
                type: "uint120",
              },
              {
                internalType: "uint128",
                name: "globalCap",
                type: "uint128",
              },
            ],
            internalType: "struct ICappedLiquidity.CapParams",
            name: "capParams",
            type: "tuple",
          },
          {
            internalType: "address",
            name: "pauseManager",
            type: "address",
          },
        ],
        internalType: "struct GyroECLPPool.GyroParams",
        name: "params",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "configAddress",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "capManager",
        type: "address",
      },
    ],
    name: "CapManagerUpdated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "capEnabled",
            type: "bool",
          },
          {
            internalType: "uint120",
            name: "perAddressCap",
            type: "uint120",
          },
          {
            internalType: "uint128",
            name: "globalCap",
            type: "uint128",
          },
        ],
        indexed: false,
        internalType: "struct ICappedLiquidity.CapParams",
        name: "params",
        type: "tuple",
      },
    ],
    name: "CapParamsUpdated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "derivedParamsValidated",
        type: "bool",
      },
    ],
    name: "ECLPDerivedParamsValidated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "paramsValidated",
        type: "bool",
      },
    ],
    name: "ECLPParamsValidated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "invariantAfterJoin",
        type: "uint256",
      },
    ],
    name: "InvariantAterInitializeJoin",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "oldInvariant",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "newInvariant",
        type: "uint256",
      },
    ],
    name: "InvariantOldAndNew",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "enabled",
        type: "bool",
      },
    ],
    name: "OracleEnabledChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "oracleUpdatedIndex",
        type: "uint256",
      },
    ],
    name: "OracleIndexUpdated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "oldPauseManager",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "newPauseManager",
        type: "address",
      },
    ],
    name: "PauseManagerChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [],
    name: "PausedLocally",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "paused",
        type: "bool",
      },
    ],
    name: "PausedStateChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "swapFeePercentage",
        type: "uint256",
      },
    ],
    name: "SwapFeePercentageChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256[]",
        name: "balances",
        type: "uint256[]",
      },
      {
        components: [
          {
            internalType: "int256",
            name: "x",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "y",
            type: "int256",
          },
        ],
        indexed: false,
        internalType: "struct GyroECLPMath.Vector2",
        name: "invariant",
        type: "tuple",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "SwapParams",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [],
    name: "UnpausedLocally",
    type: "event",
  },
  {
    inputs: [],
    name: "DOMAIN_SEPARATOR",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_dSq",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_paramsAlpha",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_paramsBeta",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_paramsC",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_paramsLambda",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_paramsS",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_tauAlphaX",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_tauAlphaY",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_tauBetaX",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_tauBetaY",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_u",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_v",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_w",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "_z",
    outputs: [
      {
        internalType: "int256",
        name: "",
        type: "int256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
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
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "balanceOf",
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
    name: "capManager",
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
    name: "capParams",
    outputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "capEnabled",
            type: "bool",
          },
          {
            internalType: "uint120",
            name: "perAddressCap",
            type: "uint120",
          },
          {
            internalType: "uint128",
            name: "globalCap",
            type: "uint128",
          },
        ],
        internalType: "struct ICappedLiquidity.CapParams",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_pauseManager",
        type: "address",
      },
    ],
    name: "changePauseManager",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "decimals",
    outputs: [
      {
        internalType: "uint8",
        name: "",
        type: "uint8",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "decreaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "startIndex",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "endIndex",
        type: "uint256",
      },
    ],
    name: "dirtyUninitializedOracleSamples",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "enableOracle",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes4",
        name: "selector",
        type: "bytes4",
      },
    ],
    name: "getActionId",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getAuthorizer",
    outputs: [
      {
        internalType: "contract IAuthorizer",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getECLPParams",
    outputs: [
      {
        components: [
          {
            internalType: "int256",
            name: "alpha",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "beta",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "c",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "s",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "lambda",
            type: "int256",
          },
        ],
        internalType: "struct GyroECLPMath.Params",
        name: "params",
        type: "tuple",
      },
      {
        components: [
          {
            components: [
              {
                internalType: "int256",
                name: "x",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "y",
                type: "int256",
              },
            ],
            internalType: "struct GyroECLPMath.Vector2",
            name: "tauAlpha",
            type: "tuple",
          },
          {
            components: [
              {
                internalType: "int256",
                name: "x",
                type: "int256",
              },
              {
                internalType: "int256",
                name: "y",
                type: "int256",
              },
            ],
            internalType: "struct GyroECLPMath.Vector2",
            name: "tauBeta",
            type: "tuple",
          },
          {
            internalType: "int256",
            name: "u",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "v",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "w",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "z",
            type: "int256",
          },
          {
            internalType: "int256",
            name: "dSq",
            type: "int256",
          },
        ],
        internalType: "struct GyroECLPMath.DerivedParams",
        name: "d",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getInvariant",
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
    name: "getLargestSafeQueryWindow",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "getLastInvariant",
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
        internalType: "enum IPriceOracle.Variable",
        name: "variable",
        type: "uint8",
      },
    ],
    name: "getLatest",
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
    name: "getMiscData",
    outputs: [
      {
        internalType: "int256",
        name: "logInvariant",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "logTotalSupply",
        type: "int256",
      },
      {
        internalType: "uint256",
        name: "oracleSampleCreationTimestamp",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "oracleIndex",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "oracleEnabled",
        type: "bool",
      },
      {
        internalType: "uint256",
        name: "swapFeePercentage",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getNormalizedWeights",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getOwner",
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
        components: [
          {
            internalType: "enum IPriceOracle.Variable",
            name: "variable",
            type: "uint8",
          },
          {
            internalType: "uint256",
            name: "ago",
            type: "uint256",
          },
        ],
        internalType: "struct IPriceOracle.OracleAccumulatorQuery[]",
        name: "queries",
        type: "tuple[]",
      },
    ],
    name: "getPastAccumulators",
    outputs: [
      {
        internalType: "int256[]",
        name: "results",
        type: "int256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getPausedState",
    outputs: [
      {
        internalType: "bool",
        name: "paused",
        type: "bool",
      },
      {
        internalType: "uint256",
        name: "pauseWindowEndTime",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "bufferPeriodEndTime",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getPoolId",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getPrice",
    outputs: [
      {
        internalType: "uint256",
        name: "spotPrice",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getRate",
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
        internalType: "uint256",
        name: "index",
        type: "uint256",
      },
    ],
    name: "getSample",
    outputs: [
      {
        internalType: "int256",
        name: "logPairPrice",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "accLogPairPrice",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "logBptPrice",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "accLogBptPrice",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "logInvariant",
        type: "int256",
      },
      {
        internalType: "int256",
        name: "accLogInvariant",
        type: "int256",
      },
      {
        internalType: "uint256",
        name: "timestamp",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getSwapFeePercentage",
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
        components: [
          {
            internalType: "enum IPriceOracle.Variable",
            name: "variable",
            type: "uint8",
          },
          {
            internalType: "uint256",
            name: "secs",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "ago",
            type: "uint256",
          },
        ],
        internalType: "struct IPriceOracle.OracleAverageQuery[]",
        name: "queries",
        type: "tuple[]",
      },
    ],
    name: "getTimeWeightedAverage",
    outputs: [
      {
        internalType: "uint256[]",
        name: "results",
        type: "uint256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getTokenRates",
    outputs: [
      {
        internalType: "uint256",
        name: "rate0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "rate1",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getTotalSamples",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "getVault",
    outputs: [
      {
        internalType: "contract IVault",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "gyroConfig",
    outputs: [
      {
        internalType: "contract IGyroConfig",
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
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "addedValue",
        type: "uint256",
      },
    ],
    name: "increaseAllowance",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
    ],
    name: "nonces",
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
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256[]",
        name: "balances",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "lastChangeBlock",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "protocolSwapFeePercentage",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "userData",
        type: "bytes",
      },
    ],
    name: "onExitPool",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256[]",
        name: "balances",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "lastChangeBlock",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "protocolSwapFeePercentage",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "userData",
        type: "bytes",
      },
    ],
    name: "onJoinPool",
    outputs: [
      {
        internalType: "uint256[]",
        name: "amountsIn",
        type: "uint256[]",
      },
      {
        internalType: "uint256[]",
        name: "dueProtocolFeeAmounts",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "enum IVault.SwapKind",
            name: "kind",
            type: "uint8",
          },
          {
            internalType: "contract IERC20",
            name: "tokenIn",
            type: "address",
          },
          {
            internalType: "contract IERC20",
            name: "tokenOut",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "amount",
            type: "uint256",
          },
          {
            internalType: "bytes32",
            name: "poolId",
            type: "bytes32",
          },
          {
            internalType: "uint256",
            name: "lastChangeBlock",
            type: "uint256",
          },
          {
            internalType: "address",
            name: "from",
            type: "address",
          },
          {
            internalType: "address",
            name: "to",
            type: "address",
          },
          {
            internalType: "bytes",
            name: "userData",
            type: "bytes",
          },
        ],
        internalType: "struct IPoolSwapStructs.SwapRequest",
        name: "request",
        type: "tuple",
      },
      {
        internalType: "uint256",
        name: "balanceTokenIn",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "balanceTokenOut",
        type: "uint256",
      },
    ],
    name: "onSwap",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "pause",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "pauseManager",
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
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "deadline",
        type: "uint256",
      },
      {
        internalType: "uint8",
        name: "v",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "r",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "s",
        type: "bytes32",
      },
    ],
    name: "permit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256[]",
        name: "balances",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "lastChangeBlock",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "protocolSwapFeePercentage",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "userData",
        type: "bytes",
      },
    ],
    name: "queryExit",
    outputs: [
      {
        internalType: "uint256",
        name: "bptIn",
        type: "uint256",
      },
      {
        internalType: "uint256[]",
        name: "amountsOut",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "poolId",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256[]",
        name: "balances",
        type: "uint256[]",
      },
      {
        internalType: "uint256",
        name: "lastChangeBlock",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "protocolSwapFeePercentage",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "userData",
        type: "bytes",
      },
    ],
    name: "queryJoin",
    outputs: [
      {
        internalType: "uint256",
        name: "bptOut",
        type: "uint256",
      },
      {
        internalType: "uint256[]",
        name: "amountsIn",
        type: "uint256[]",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "rateProvider0",
    outputs: [
      {
        internalType: "contract IRateProvider",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "rateProvider1",
    outputs: [
      {
        internalType: "contract IRateProvider",
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
        name: "_capManager",
        type: "address",
      },
    ],
    name: "setCapManager",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "capEnabled",
            type: "bool",
          },
          {
            internalType: "uint120",
            name: "perAddressCap",
            type: "uint120",
          },
          {
            internalType: "uint128",
            name: "globalCap",
            type: "uint128",
          },
        ],
        internalType: "struct ICappedLiquidity.CapParams",
        name: "params",
        type: "tuple",
      },
    ],
    name: "setCapParams",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "paused",
        type: "bool",
      },
    ],
    name: "setPaused",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "swapFeePercentage",
        type: "uint256",
      },
    ],
    name: "setSwapFeePercentage",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
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
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "unpause",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;
