// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Stablecoin is ERC20{

    using SafeMath for uint256;
    error MustBeGreaterThanZero();
    error TokenBalanceShouldBeDouble();
    error TrasanctionFailed();
     
    event Deposit(address indexed from,uint indexed Colletal,uint indexed  token);
    event Redeem(address  indexed to, uint indexed ethamount,uint nusdAmount);


    
    address private oracleAddress; // Chainlink Oracle address
    uint8 public immutable depositFeePercentage;
    mapping(address => uint256) private ethBalances; // User ETH balances
    mapping(address => uint256) private nusdBalances; // User nUSD balances
    
    constructor(address _oracleAddress, uint8 _depositFeePercentage) ERC20("nUSD", "nUSD") {
        oracleAddress = _oracleAddress;
        depositFeePercentage = _depositFeePercentage;
        
    }
    
    // Deposit ETH and receive nUSD
    function deposit() external payable {
        //require(msg.value > 0, "ETH amount must be greater than 0");
         if(msg.value <= 0){
             revert MustBeGreaterThanZero(); 
         }
        uint256 ETHperUSD = getEthPrice();
        uint256 colletalValue= (ETHperUSD.mul(msg.value)).div(1e18);
      
        
        uint256 nusdAmount = colletalValue.div(2); // 50% conversion rate
      
        // Apply deposit fee
        uint256 depositFee = (nusdAmount.mul(depositFeePercentage)).div(100);
        nusdAmount -= depositFee;
        
        
        ethBalances[msg.sender] += colletalValue;
        nusdBalances[msg.sender] += nusdAmount;
        _mint(msg.sender, nusdAmount);
        emit Deposit( msg.sender,msg.value,nusdAmount);
    }
    
    // Redeem nUSD for ETH
    function redeem(uint256 nusdAmount) external {
       
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
        
        (bool success,) = msg.sender.call{value:ethAmount}("");
        if(!success){
            revert TrasanctionFailed();
        }
        emit Redeem(msg.sender,ethAmount,nusdAmount);
    }
    
    // Get the current ETH price from the Chainlink Oracle
    function getEthPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(oracleAddress);
        (, int256 price, , ,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid ETH price");
        return uint256(price)/1e8;
    }
    
    // Get user ETH balance
    function getEthBalance(address user) external view returns (uint256) {
        return ethBalances[user];
    }
    
    // Get user nUSD balance
    function getNusdBalance(address user) external view returns (uint256) {
        return nusdBalances[user];
    }
}
