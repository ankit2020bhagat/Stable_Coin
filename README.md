Stablecoin (nUSD)
Stablecoin (nUSD) is a Solidity smart contract that implements a stablecoin on the Ethereum blockchain. The contract allows users to deposit Ether (ETH) and receive nUSD tokens in return, which are pegged to the value of the US Dollar. Users can also redeem their nUSD tokens for ETH.

Features
Deposit ETH and receive nUSD tokens.
Redeem nUSD tokens for ETH.
Automatic conversion rate based on the Chainlink ETH-USD price oracle.
Deposit fee of a configurable percentage (specified during contract deployment).
Prerequisites
Solidity compiler (version ^0.8.18)
Truffle framework (optional)
Chainlink AggregatorV3Interface (imported as a dependency)
OpenZeppelin ERC20 contract (imported as a dependency)
Interact with the Stablecoin contract using the provided functions.
Usage
The Stablecoin contract provides the following functions:

deposit(): Allows users to deposit ETH and receive nUSD tokens. The deposited ETH amount is converted to nUSD based on the current ETH-USD exchange rate obtained from the Chainlink oracle. A deposit fee is applied, which is a percentage of the converted nUSD amount.
redeem(uint256 nusdAmount): Allows users to redeem their nUSD tokens for ETH. The provided nusdAmount specifies the number of nUSD tokens to redeem. The nUSD tokens are burned, and the corresponding ETH amount is transferred to the user's address.
getEthPrice(): Retrieves the current ETH price in USD from the Chainlink oracle.
getEthBalance(address user): Retrieves the ETH balance of a specific user.
getNusdBalance(address user): Retrieves the nUSD token balance of a specific user.
