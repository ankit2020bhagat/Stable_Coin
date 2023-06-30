// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./PriceFeed.sol";

/**
 * @title Stablecoin
 * @dev A stablecoin contract that allows users to deposit ETH and receive nUSD tokens.
 */
contract Stablecoin is ReentrancyGuard,Pausable,ERC20,AccessControl{

    using SafeMath for uint256;

    // Error messages
    error MustBeGreaterThanZero();
    error TokenBalanceShouldBeDouble();
    error TrasanctionFailed();
    error AccessControlUnauthorizedAccount();
    error InvalidETHprice();
    
        // Events
    event Deposit(address indexed from,uint indexed Colletal,uint indexed  token);
    event Redeem(address  indexed to, uint indexed ethamount,uint nusdAmount);


    // Chainlink price feed contract
    DataConsumerV3 immutable dataFeed;

     bytes32 public constant PAUSABLE_ROLE = keccak256("PAUSABLE_ROLE");
   

    
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
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(PAUSABLE_ROLE, DEFAULT_ADMIN_ROLE);
        
    }
    
    /**
     * @dev Deposit ETH and receive nUSD tokens.
     */
    function deposit() external payable whenNotPaused{
        //require(msg.value > 0, "ETH amount must be greater than 0");
         if(msg.value <= 0){
             revert MustBeGreaterThanZero(); 
         }
        uint256 ETHperUSD = getEthPrice();
        uint256 colletalValue= (ETHperUSD.mul(msg.value)).div(1e18);
      
        
        uint256 nusdAmount = colletalValue.div(2); // 50% conversion rate 
        colleteralDeposit[msg.sender] += msg.value;
        nusdBalances[msg.sender] += nusdAmount;
        _mint(msg.sender, nusdAmount);
        emit Deposit( msg.sender,msg.value,nusdAmount);
    }
    
    /**
     * @dev Redeem nUSD tokens for ETH.
     * @param nusdAmount The amount of nUSD tokens to redeem.
     */
    function redeem(uint256 nusdAmount) external nonReentrant whenNotPaused{
       
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
        
        if(price<=0){
        revert InvalidETHprice(); 
        }
        return uint256(price);
        
    }

   
    /**
     *@dev Checks if an account has the specified role or the default admin role.
     *@param role The role to check.
     *@param account The account address to check.
     *@dev Throws an exception if the account doesn't have the role or the default admin role. 
    */
     function _checkRole(bytes32 role, address account) internal override  view virtual {
        if (!(hasRole(role, account) || hasRole(DEFAULT_ADMIN_ROLE,account))){
            revert AccessControlUnauthorizedAccount();
        }
    }
    
    // Get user ETH balance
    function getEthBalance(address user) external view returns (uint256) {
        return colleteralDeposit[user];
    }
    
    // Get user nUSD balance
    function getNusdBalance(address user) external view returns (uint256) {
        return nusdBalances[user];
    }

/// @dev Pauses the contract.
/// @dev Only callable by an account with the PAUSABLE_ROLE.
/// @dev Throws an exception if the contract is already paused.
    function pause() external onlyRole(PAUSABLE_ROLE) whenNotPaused {
        _pause();
    }

/// @dev Unpauses the contract.
/// @dev Only callable by an account with the PAUSABLE_ROLE.
/// @dev Throws an exception if the contract is not currently paused.
    function unpause() external onlyRole(PAUSABLE_ROLE) whenPaused {
        _unpause();
    }
}
