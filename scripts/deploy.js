// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { expect } = require("chai");
const { ethers, BigNumber } = require("hardhat");

async function main() {
  
  const Filmrare = await ethers.getContractFactory("Volt");
  factoryContract = await Filmrare.deploy("0xeD35D3276C6535A44fae66525CaAE6F8182eb9F1");
  await factoryContract.deployed();

  factoryAddress = factoryContract.address;
  console.log(factoryAddress, " Factory address");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
