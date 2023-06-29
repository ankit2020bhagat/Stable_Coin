// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PriceFeed.sol";

/**
 * @title Stablecoin
 * @dev A stablecoin contract that allows users to deposit ETH and receive nUSD tokens.
 */
contract Stablecoin is ReentrancyGuard,ERC20{

    using SafeMath for uint256;

    // Error messages
    error MustBeGreaterThanZero();
    error TokenBalanceShouldBeDouble();
    error TrasanctionFailed();
    
        // Events
    event Deposit(address indexed from,uint indexed Colletal,uint indexed  token);
    event Redeem(address  indexed to, uint indexed ethamount,uint nusdAmount);


    // Chainlink price feed contract
    DataConsumerV3 immutable dataFeed;

     // Deposit fee percentage
   

    
   // User balances
    mapping(address => uint256) private colleteralDeposit; // User ETH balances
    mapping(address => uint256) private nusdBalances; // User nUSD balances
    
    /**
     * @dev Initializes the Stablecoin contract.
     * @param _oracleDataFeedAddress The address of the Chainlink Oracle contract.
     *
     */
    constructor(address _oracleDataFeedAddress) ERC20("nUSD", "nUSD") {
        dataFeed = DataConsumerV3(_oracleDataFeedAddress);
        
        
    }
    
    /**
     * @dev Deposit ETH and receive nUSD tokens.
     */
    function deposit() external payable {
        //require(msg.value > 0, "ETH amount must be greater than 0");
         if(msg.value <= 0){
             revert MustBeGreaterThanZero(); 
         }
        uint256 ETHperUSD = getEthPrice();
        uint256 colletalValue= (ETHperUSD.mul(msg.value)).div(1e18);
      
        
        uint256 nusdAmount = colletalValue.div(2); // 50% conversion rate
      
        // Apply deposit fee
       
        
        
        colleteralDeposit[msg.sender] += msg.value;
        nusdBalances[msg.sender] += nusdAmount;
        _mint(msg.sender, nusdAmount);
        emit Deposit( msg.sender,msg.value,nusdAmount);
    }
    
    /**
     * @dev Redeem nUSD tokens for ETH.
     * @param nusdAmount The amount of nUSD tokens to redeem.
     */
    function redeem(uint256 nusdAmount) external nonReentrant{
       
        if(nusdAmount<=0){
            revert MustBeGreaterThanZero();
        }
        if(nusdBalances[msg.sender]< nusdAmount*2){
            revert TokenBalanceShouldBeDouble();
        }
        uint256 Ether = 1e18;
        uint256 ethAmount = (Ether.mul(nusdAmount)).div(getEthPrice());
        
        nusdBalances[msg.sender] -= nusdAmount;
        _burn(msg.sender, nusdAmount);
        colleteralDeposit[msg.sender]-=ethAmount;
        (bool success,) = msg.sender.call{value:ethAmount}("");
        if(!success){
            revert TrasanctionFailed();
        }
        emit Redeem(msg.sender,ethAmount,nusdAmount);
    }
    
    // Get the current ETH price from the Chainlink Oracle
    function getEthPrice() public view  returns (uint256) {
       
        int price = dataFeed.getLatestData();
        require(price > 0, "Invalid ETH price");
        return uint256(price);
       
       
    }
    
    // Get user ETH balance
    function getEthBalance(address user) external view returns (uint256) {
        return colleteralDeposit[user];
    }
    
    // Get user nUSD balance
    function getNusdBalance(address user) external view returns (uint256) {
        return nusdBalances[user];
    }
}
