//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Exchange
 * @author Rahul Prasad
 * @dev This contract is used to Build an exchange that allows swapping ETH <> TOKEN
 * @notice DEX must charge a 1% fee on swaps, and send those fees to a wallet address
 * @notice When user adds liquidity, they must be given an LP Token that represents their share of the pool
 * @dev LP must be able to burn their LP tokens to receive back ETH and TOKEN
 */
contract Exchange is ERC20 {

    address public tokenAddress;
    
    
    /**
     * @notice This constructor takes the contract address of the token. 
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

    /**
     * @notice addLiquidity function allows users to add liquidity to the exchange
     * @param amountOfToken The amount of Liquidity to add in exchnage
     * @return uint256 The amount of LP tokens minted to represent the share of the pool
     * @notice calculating the minimum amount of token required to be transferred to the exchange =  x*deltaY / y - deltaX 
     * @notice calculating the minimum amount of ETH required to be transferred to the exchange =  y*deltaX / x + deltaY
     * 
     * Now the question is do we add only Eth or only token or both? while adding liquidity
     * 
     */
    function addLiquidity(uint256 amountOfToken) public payable returns (uint256){

        uint256 lpTokenToMint;
        uint256 ethReserveBalance  =  address(this).balance;
        uint256 tokenReserveBalance =  getReserve();

        ERC20 token = ERC20(tokenAddress);

        if(tokenReserveBalance == 0 ){
            token.transferFrom(msg.sender, address(this), amountOfToken);

            lpTokenToMint = ethReserveBalance;

            _mint(msg.sender, lpTokenToMint);

            return lpTokenToMint;
        }

        uint256 ethReservePriorToFunctionCall = ethReserveBalance - msg.value;
        
        // calculating the minimum amount of token required to be transferred to the exchange =  x*deltaY / y - deltaX 
        // x*deltaY / y - deltaX = deltaX
        // (msg.value * tokenReserveBalance) / ethReservePriorToFunctionCall = minTokenAmountRequired
        // where x - amount of token reserved, y - amount of eth reserved
        // where deltaX - amount of eth sent by the user, deltaY - amount of token sent by the user
        uint256 minTokenAmountRequired = (msg.value * tokenReserveBalance) / ethReservePriorToFunctionCall;

        require(amountOfToken >= minTokenAmountRequired, "Insufficient amount of token passed");

        // transfer token from the user to exchange
        token.transferFrom(msg.sender, address(this), minTokenAmountRequired);

        // calculate the amount of LP tokens to mint
        lpTokenToMint = (msg.value * totalSupply()) / ethReservePriorToFunctionCall;

        // mint the LP tokens to the user
        _mint(msg.sender, lpTokenToMint);

        return lpTokenToMint;


    }



}