require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  // paths: {
  //   artifacts: "../app/src/artifacts",
  // },

  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    sepolia: {
      url: process.env.SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    noColors: true,
    token: "ETH",
    gasPriceApi: "api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    outputFile: "gas-report.txt",
    coinmarketcap: process.env.COINMARKETCAP,
    noColors: true,
  },
  mocha: {
    timeout: 50000,
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API,
    },
  },
};
