// Import the required libraries
const { expect } = require("chai");
const { ethers } = require("hardhat");

// Describe the contract and its tests
describe.only("DataConsumerV3", function () {
  let dataConsumer;
  let aggregatorMock;
  it("", async function () {
    aggregatorMock = await ethers.deployContract("AggregatorV3Interface", []);
    await aggregatorMock.waitForDeployment();
    dataConsumer = await ethers.deployContract("DataConsumerV3", []);
    await dataConsumer.waitForDeployment();
    await dataConsumer.setAggregator(aggregatorMock.target);
  });
  // Test the getLatestData function
  describe("getLatestData", function () {
    it("should return the latest data from the aggregator", async function () {
      const latestAnswer = 100000000; 
      const txn = await aggregatorMock.latestRoundData();
      await txn.wait();
      // Get the latest data
      const result = await dataConsumer.getLatestData();

      // Check the result
      expect(result).to.equal(latestAnswer);
    });
  });
});
