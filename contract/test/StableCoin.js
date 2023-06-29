const { ethers } = require("hardhat");
const { ORACLEADDRESS } = require("../helper-config");

describe("Stablecoin contracts", function () {
  let stableCoin, accounts;
  it("", async function () {
    [...accounts] = await ethers.getSigners();
    stableCoin = await ethers.deployContract("Stablecoin", [ORACLEADDRESS, 10]);
    await stableCoin.waitForDeployment();
    console.log("contracts Deployed at :", stableCoin.target);
  });
  it("deposit colletral and minting nUSD coin", async function () {
    const depositTxn = await stableCoin.deposit({
      value: ethers.utils.parseEther("1.0"),
    });
    await depositTxn.wait();
    const nUSDBalance = await stableCoin.getNusdBalance(accounts[0].address);
    console.log("nUSD Balance ", await nUSDBalance.toString());
    const etherBalance = await stableCoin.getEthBalance(accounts[0].address);
    console.log("ETH Balance ", etherBalance.toString());
    const totalSupply = await stableCoin.totalSupply();
    console.log("Total Balance", totalSupply.toString());
  });

  it("withdraw colleteral ", async function () {
    let nUSDamount = 100;
    const redeemTxn = await stableCoin.redeem(nUSDamount);
    await redeemTxn.wait();
    console.log("nUSD Balance ", await nUSDBalance.toString());
    const etherBalance = await stableCoin.getEthBalance(accounts[0].address);
    console.log("ETH Balance ", etherBalance.toString());
    const totalSupply = await stableCoin.totalSupply();
    console.log("Total Balance", totalSupply.toString());
  });
});
