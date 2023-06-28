const hre = require("hardhat");
const { oracleAddress } = require("../helper-config/ORACLEADDRESSS");
async function main() {
  console.log(oracleAddress);
  const stablecoin = await hre.ethers.deployContract("Stablecoin", [
    oracleAddress,
    10,
  ]);

  await lock.waitForDeployment();
  console.log("Contract deployed at :", stablecoin.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
