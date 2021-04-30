require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy')
require('hardhat-deploy-ethers')
require('solidity-coverage')
require('hardhat-abi-exporter')
require('hardhat-dependency-compiler')

const networks = require('./hardhat.networks')

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          evmVersion: "istanbul"
        }
      },
      {
        version: "0.6.12",
        settings:{
          optimizer: {
            enabled: true,
            runs: 200
          },
          evmVersion:"istanbul"
        }
      }
    ]
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  namedAccounts: {
    deployer: {
      default: 0
    },
    MultiSig: {
      default : 0,
      1: "0x77383BaDb05049806d53e9def0C8128de0D56D90",
      4: "0x72c9aA4c753fc36cbF3d1fF6fEc0bC44ad41D7f2"
    },
    prizePoolRegistry: {
      4: "0xb9D70C3d7E4453Cc679D8A91145a28782268f229"
    }
  },
  networks,
  abiExporter: {
    path: './abis',
    clear: true,
    flat: true
  },
  dependencyCompiler: {
    paths: [
      '@pooltogether/pooltogether-generic-registry/contracts/AddressRegistry.sol'
    ]
  }
};
