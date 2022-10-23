# Ethernaut Walkthrough: Good Samaritan
## Welcome to KweenBirb's 28th and final installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GoodSamaritan.sol, the 28th and final challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in the ./src directory. Let's begin!

In this challenge, Ethernaut describes a generous philanthropist who has written a contract that dispenses tokens to any poor soul destitute enough to request some. It is of course hinted that we are 'able to drain all the balance from his Wallet.' That will be our objective.

Looking over the codebase, we note a three-contract structure:

1. a Coin contract with a very basic implementation of the token, token balances, and token transfers. This is not unlike a very simple ERC20

2. a Wallet contract that handles the preset methods of using the Coin's transfer functions. It provides a way to donate10() tokens to any poor soul in need as well as a backup function that handles the edge case where the balance of tokens is lower than 10. In this case, donate10() will not suffice and transferRemainder() instead provides a way to move the rest of the tokens

3. a GoodSamaritan contract that acts as both a registry and an interface for the Wallet and Coin contracts. It provides a single function requestDonation() that will call one of the two Wallet functions depending on the situation.

In essence, we're presented with two layers of abstraction on top of the Coin token contract, with the GoodSamaritan on top. Because the Wallet contract holds many more tokens than 10 and our objective is to drain the Wallet entirely, the function of most interest to us in this scenario is its transferRemainder() method.

## How then to trigger transferRemainder() ?

The GoodSamaritan contract is the user-facing instance contract here, and it gives us a way to call wallet.transferRemainder() but only within a try{} catch{} block meant for a specific edge case error scenario. Let's inspect that logic:

```
function requestDonation() external returns(bool enoughBalance){
    // donate 10 coins to requester
    try wallet.donate10(msg.sender) {
        return true;
    } catch (bytes memory err) {
        if (keccak256(abi.encodeWithSignature("NotEnoughBalance()")) == keccak256(err)) {
            // send the coins left
            wallet.transferRemainder(msg.sender);
            return false;
        }
    }
}
```

It's evident that we will need the ```wallet.donate10(msg.sender)``` call to fail and return bytes memory error equivalent to ```keccak256(abi.encodeWithSignature("NotEnoughBalance()"))```

All right, let's go a level of abstraction deeper.

## Into the Wallet's logic

Since we know ```wallet.donate10()``` will be called before we can successfully drain anything, let's get an understanding of that function:

```
function donate10(address dest_) external onlyOwner {
    // check balance left
    if (coin.balances(address(this)) < 10) {
        revert NotEnoughBalance();
    } else {
        // donate 10 coins
        coin.transfer(dest_, 10);
    }
}
```

Here the edge case for when the Wallet contract's Coin token balance has fallen below 10 presents itself. In this case, the Wallet has presumably been Sybil attacked or simply performed its purpose and generously distributed wealth to a horde of people who've fallen on hard times.

When GoodSamaritan invokes Wallet's donate10(), it reverts execution and bubbles up a custom error: NotEnoughBalance(). So that's what causes GoodSamaritan to exit its try{} block and move to the catch{} block that transfers the remainder of Wallet's token balance to the caller.

Have we hit a dead end? Possibly. But to be sure, let's eliminate all doubt and dig the last layer of abstraction down to the Coin token contract just in case.

## To the bottom layer: the Coin contract

If the Wallet contract has a dearth of tokens at its disposal, which it currently does in our case, no custom error is emitted and Wallet invokes Coin's transfer function, providing 10 tokens as parameter. Normally, this would be the end of our exploitative investigation, but there's something of interest in Coin's transfer function. Have a look:

```
function transfer(address dest_, uint256 amount_) external {
    uint256 currentBalance = balances[msg.sender];

    // transfer only occurs if balance is enough
    if(amount_ <= currentBalance) {
        balances[msg.sender] -= amount_;
        balances[dest_] += amount_;

        if(dest_.isContract()) {
            // notify contract 
            INotifyable(dest_).notify(amount_);
        }
    } else {
        revert InsufficientBalance(currentBalance, amount_);
    }
}
```

Can you spot it?

That's right, an external call. Scary stuff, handing execution to an external contract. Even moreso, an external contract that in this codebase is only thinly outlined as an interface, which is set by the user's msg.sender. Absolutely hair-raisingly terrifying!

Any user is able to implement a contract complying with the INotifyable interface, which is handed the execution of every transfer done by the Coin contract, including every donation made by the GoodSamaritan.

How can we exploit this external call? How about we use a custom error injection to spoof a specific error that bubbles up to the GoodSamaritan contract's requestDonation() function and causes it to execute transferRemainder(), even when the Wallet's balance is not low? 

See where this is going? We can implement an INotifyable contract that simply returns a clone of the Wallet contract's NotEnoughBalance() custom error!

## Implementing a malicious INotifyable interface

Now that we've identified an exploit, let's get to it. As mentioned in previous walkthroughs, Foundry is the most powerful Solidity framework out there and that's what I used to come up with this solution. If you're interested in seeing the process used to complete this challenge, those steps can be found in the Solution.t.sol file of the test directory.

A few things are necessary to start with before we can take advantage of this Good Samaritan's goodwill. The first is that we will want to import the GoodSamaritan codebase into our contract. 

```import "./GoodSamaritan.sol";```

An interface will also suffice, but importing is faster since the GoodSamaritan.sol file outlines the INotifyable interface for us so we don't need to define it twice.

The second housekeeping item we need to do is inherit the INotifyable interface so that the Coin implementation in GoodSamaritan.sol will recognize our malicious contract as an INotifyable contract and call notify() on it without causing a revert().

```contract ErrorInjection is INotifyable {}```

The final groundwork we need to lay before writing functions to hack GoodSamaritan is of course a spoofed replica of the custom error originated by the Wallet contract that will then be returned to GoodSamaritan to trick it into emptying itself.

```error NotEnoughBalance()```

## Implementing the notify() exploit function

The Coin token contract will call into our exploit function using the 4 byte function signature for 'notify(uint256)' so we need to call the exploit function notify() and give it the spoofed custom error we added.

Since the objective is cause a guaranteed revert with our custom spoof error, we can use the uint parameter that will always be passed along with the call from GoodSamaritan to do so:

```
function notify(uint amount) external {
    if (amount == 10) { 
        revert NotEnoughBalance(); 
    } else {
        return;
    }
}
```

Now GoodSamaritan will be sure to exit its try {} block and move onto the catch {} block we're interested in.

All that's left to do is provide a function to initiate the exploit transaction:

```
function inject() public {
    goodSamaritan.requestDonation();
}
```

Congratulations, anon. You're officially an Ethernaut.

○•○ h00t h00t ○•○