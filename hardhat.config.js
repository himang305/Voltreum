require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    testnet: {
      url: "https://data-seed1.gdccoin.io/",
      chainId: 6796,
      accounts: ["86dff4ceb17c9e487a75826ece38e31ca9d42d40269662f0900f6392f6234401"]
    },
    mainnet: {
      url: "https://mainnet-rpc1.gdccoin.io/",
      chainId: 7777,
      accounts: ["d1a7703c35addf9c175ae5e4b8a5228c957eedad05c5871e61542de1c9966ef6"]
    },
    bsctestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      accounts: ["86dff4ceb17c9e487a75826ece38e31ca9d42d40269662f0900f6392f6234401"]
    },
    bscmainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: ["d1a7703c35addf9c175ae5e4b8a5228c957eedad05c5871e61542de1c9966ef6"]
    }
  },
  etherscan: {
    apiKey: "1ZYIJGHQA2BCB5NA5JBH2RWR4I9WUGS3DK"
  }
};
