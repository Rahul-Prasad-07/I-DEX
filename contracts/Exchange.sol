//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Exchange
 * @author Rahul Prasad
 * @notice  This contract is used to create LP tokens for the exchange
 */
contract Exchange is ERC20 {

    address public tokenAddress;
    
    
    /**
     * @notice This constructor takes the contract address of the token and saves it. 
     * The exchange will then further behave as an exchange for ETH <> Token.
     * @param token Address of the token to be used for liquidity
     */
    constructor(address token) ERC20("ETH TOKEN LP Token","LpETHTOKEN") {

        require(token != address(0), "Token address passed is null address");
        tokenAddress = token;

    }
    
    /**
     * @notice This function is used to get the reserve of the token in the exchange
     * @return uint256 The amount of token in the exchange
    */
    function getReserve() public view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // Add Liquidity
    function addLiquidity(uint256 amountOfToken) public payable returns (uint256){

    }



}