# I-DEX

Inter-planetary decentralized exchange

This is the Version R1 of this Decentralized Exchange

Deployed address
Token : 0x3965a9f71dDF5f847C5c76F6743085f4D418AD82
Exchange : 0x3703ff1916f2933e94BDA4A48bF4FEad2fd1d6F0

verified contract Token on the block explorer
Token : https://sepolia.etherscan.io/address/0x3965a9f71dDF5f847C5c76F6743085f4D418AD82#code

Exchange : https://sepolia.etherscan.io/address/0x3703ff1916f2933e94BDA4A48bF4FEad2fd1d6F0#code

### Test on Etherscan

Let's now test that everything works by playing around with our contracts on Etherscan.

Open up both contracts - the Token and the Exchange - on Sepolia Etherscan - https://sepolia.etherscan.io/

You should have some TOKEN in the account you used to deploy the contract.

### Adding Liquidity

Let's start off by trying to add some liquidity to the exchange. The Exchange relies on the ERC-20 Approve and Transfer Flow, so we need to go give it allowance for TOKEN from the Token contract.

On the TOKEN contract on Etherscan, go to the Contract tab and then Write Contract. Connect your wallet to that page, and click on approve

Input the Exchange contract address in the spender field, and set amount to 10000000000000000000. Click on Write and confirm that transaction.

Once that transaction goes through, open up the Exchange contract on Etherscan - and go to Contract → Write Contract and connect your wallet there.

Click on addLiquidity and input some values for payableAmount and amountOfToken. I chose 0.1 and 10000000 respectively - but feel free to do whatever you'd like. Just make sure that amountOfToken is less than or equal to the amount you previously approved. Click on View your transaction and wait for the trasnaction to go through. You will notice that some TOKENs were transfered out of your wallet into the Exchange, and then some new ETH TOKEN LP tokens were transfered into your wallet.

### Swap

Now with some liquidity in our exchange, let's try to swap. I'm gonna first try to do an ETH → Token Swap. Click on the ethToTokenSwap function under Write Contract and input a payableAmount and minTokensToReceive. Since I only added 0.1 ETH in liquidity, I put in 0.01 ETH for the payableAmount and 0 for the minTokensToReceive.

Click Write and then View your transaction. Wait for it to go through. You will notice that you received some amount of TOKEN back to you in exchange for your ETH.

Similarly, let's try a tokenToEthSwap. I'm gonna do 10000 for tokensToSwap and then 0 for minEthToReceive. Click Write and then View your transaction.

NOTE: Normally, the minimum amount to receive is not set to zero. It is the job of the client (website, app, etc) to provide an estimate on how much tokens the user will receive before they even attempt a swap, and then the user agrees to a slippage percentage. So for example, if I was told to expect 100 TKN back for my swap, and I agree to 5% slippage - that means the minimum I will get is 95% of the original estimated amount i.e. 95 TKN - else the transaction will fail

Same here - I got some ETH back for my tokens!

### Removing Liquidity

Let's check how much LP tokens I have exactly and let's try to remove some of the liquidity.

Go to the Read Contract tab on the Exchange on Etherscan, and check the balanceOf for your own address. This should tell you the balance of how many LP tokens you own. For me, that was 100000000000000000.

Now, go back to Write Contract and then remove liquidity. Put down an amountOfLPTokens less than your balance - I did 5000000000000 and then Write and View your transaction. Wait for it to go through.

Once the transaction is successful, you'll notice you get back some amount of ETH and some amount of TOKEN back.
