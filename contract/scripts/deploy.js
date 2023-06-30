const hre = require("hardhat");
const { ORACLEADDRESS } = require("../helper-config");
const { verify } = require("../utils/verify");
async function main() {
  const dataFeed = await hre.ethers.deployContract("DataConsumerV3", [
    ORACLEADDRESS,
  ]);
  await dataFeed.waitForDeployment();

  const stablecoin = await hre.ethers.deployContract("Stablecoin", [
    dataFeed.target,
  ]);

  await stablecoin.waitForDeployment();
  console.log("Contract deployed at :", stablecoin.target);
  await stablecoin.deploymentTransaction().wait(10);
  await verify(stablecoin.target, [dataFeed.target]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
