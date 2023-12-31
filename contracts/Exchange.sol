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
     * @notice Add liquidity by paying eth and transfering tokens to the exchange
     * @param amountOfToken The amount of Liquidity to add in exchnage or  represents the amount of tokens transfered
     * @return uint256 The amount of LP tokens minted to represent the share of the pool
     * @dev When somebody adds liquidity, they get LP tokens
     * @dev If the exchange has a ration of token/eth then the amount of tokens/eth added should respect it
     * @notice calculating the minimum amount of token required to be transferred to the exchange =  x*deltaY / y - deltaX 
     * @notice calculating the minimum amount of ETH required to be transferred to the exchange =  y*deltaX / x + deltaY
     * 
     * Now the question is do we add only Eth or only token or both? while adding liquidity
     * Adding liquidity involves adding tokens from both sides of the trading pair - you cannot add liquidity for just one side.
     * @notice This function accepts ETH and a token from the user.
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

        uint256 ethReserve = ethReserveBalance - msg.value;
        
        // calculating the minimum amount of token required to be transferred to the exchange =  x*deltaY / y - deltaX 
        // x*deltaY / y - deltaX = deltaX
        // (msg.value * tokenReserveBalance) / ethReserve = minTokenAmountRequired
        // where x - amount of token reserved, y - amount of eth reserved
        // where deltaX - amount of eth sent by the user, deltaY - amount of token sent by the user
        uint256 minTokenAmountRequired = (msg.value * tokenReserveBalance) / ethReserve;

        require(amountOfToken >= minTokenAmountRequired, "Insufficient amount of token passed");

        // transfer token from the user to exchange
        token.transferFrom(msg.sender, address(this), minTokenAmountRequired);

        // calculate the amount of LP tokens to mint
        lpTokenToMint = (msg.value * totalSupply()) / ethReserve;

        // mint the LP tokens to the user
        _mint(msg.sender, lpTokenToMint);

        return lpTokenToMint;


    }

    /**
     * 
     * @param amountOfLPTokens The amount of LP tokens to burn
     * @return  uint256 The amount of eth and token returned to the user
     * @dev When somebody removes liquidity, they get ETH and TOKEN
     * @dev The amount of eth and token returned to the user should be in proportion to the amount of LP tokens burned
     * @notice calculating the amount of eth to return to the user = ethReserveBalance * amountOfLPTokens / lpTokenTotalSupply
     */
    function removeLiquidity(uint256 amountOfLPTokens) public returns (uint256, uint256){

        // check that user wants to remove > 0 LP tokens
        require(amountOfLPTokens > 0, "Amount of LP tokens passed is 0");

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokenTotalSupply =  totalSupply();

        // calculate the amount of eth and token to return to the user
        uint256 ethToReturn = (ethReserveBalance * amountOfLPTokens) / lpTokenTotalSupply;

        uint256 tokenToReturn = (getReserve() * amountOfLPTokens)/ lpTokenTotalSupply;

        // Burn the LP tokens from the user and transfer the eth and token to the user
        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(tokenAddress).transfer(msg.sender, tokenToReturn);

        return (ethToReturn, tokenToReturn);
    }

   
    
    /**
     * dosen't understand this function
     * @param inputAmount The amount of token to swap
     * @param inputReserve  The amount of token in the exchange
     * @param outputReserve  The amount of DeltaX 
     */
    function getAmountFromSwap(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns(uint256){
        require(inputReserve > 0 && outputReserve > 0, "Reserve must be greater than 0");

        uint256 inputAmountWithFee = inputAmount * 99;

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }
    
    /**
     * THis function ethToTokenSwap allows users to swap ETH for tokens
     * @param minTokenToReceive The minimum amount of token to receive
     * @notice calling the getAmountFromSwap function to calculate the amount of token to receive
     */
    function ethToTokenSwap (uint256 minTokenToReceive) public payable {
        uint256 tokenReserveBalance = getReserve();
        uint256 tokenToReceive = getAmountFromSwap(msg.value, address(this).balance - msg.value, tokenReserveBalance);

        require(tokenToReceive >= minTokenToReceive, "Tokens received are less than minimum tokens expected");

        ERC20(tokenAddress).transfer(msg.sender, tokenToReceive);
    }
    

    /**
     * 
     * @param tokenToSwap The amount of token to swap
     * @param minEThToReceive  The minimum amount of eth to receive
     */
    function tokenToEthSwap(uint256 tokenToSwap, uint256 minEThToReceive) public {

        uint256 tokenReserveBalance =  getReserve();

        uint256 ethToReceive = getAmountFromSwap(tokenToSwap, tokenReserveBalance, address(this).balance);

        require(ethToReceive >= minEThToReceive, "Eth received is less than minimum eth expected");

        ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenToSwap);

        payable(msg.sender).transfer(ethToReceive);
        

    }



}