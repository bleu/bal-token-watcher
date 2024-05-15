export const AggregatorConverterAbi = [
  {
    type: "constructor",
    inputs: [
      {
        name: "_aggregator",
        type: "address",
        internalType: "address",
      },
      {
        name: "_divisor",
        type: "int256",
        internalType: "int256",
      },
      {
        name: "_description",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "nonpayable",
  },
  {
    type: "fallback",
    stateMutability: "payable",
  },
  {
    type: "receive",
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "AGGR_ADDR",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "DECIMALS",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "DIVISOR",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "int256",
        internalType: "int256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "description",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getAnswer",
    inputs: [
      {
        name: "roundId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "",
        type: "int256",
        internalType: "int256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRoundData",
    inputs: [
      {
        name: "_roundId",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    outputs: [
      {
        name: "roundId",
        type: "uint80",
        internalType: "uint80",
      },
      {
        name: "answer",
        type: "int256",
        internalType: "int256",
      },
      {
        name: "startedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "updatedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "answeredInRound",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "latestAnswer",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "int256",
        internalType: "int256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "latestRoundData",
    inputs: [],
    outputs: [
      {
        name: "roundId",
        type: "uint80",
        internalType: "uint80",
      },
      {
        name: "answer",
        type: "int256",
        internalType: "int256",
      },
      {
        name: "startedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "updatedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "answeredInRound",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "proposedGetRoundData",
    inputs: [
      {
        name: "roundId",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    outputs: [
      {
        name: "id",
        type: "uint80",
        internalType: "uint80",
      },
      {
        name: "answer",
        type: "int256",
        internalType: "int256",
      },
      {
        name: "startedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "updatedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "answeredInRound",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "proposedLatestRoundData",
    inputs: [],
    outputs: [
      {
        name: "id",
        type: "uint80",
        internalType: "uint80",
      },
      {
        name: "answer",
        type: "int256",
        internalType: "int256",
      },
      {
        name: "startedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "updatedAt",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "answeredInRound",
        type: "uint80",
        internalType: "uint80",
      },
    ],
    stateMutability: "view",
  },
] as const;
