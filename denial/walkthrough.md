# Ethernaut Walkthrough: Denial
## Welcome to KweenBirb's 21st installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Denial.sol, the 21st challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that to beat this level we must 'deny the owner from withdrawing funds when they call withdraw().'

Based on the information given, the withdraw() function's code seems like a logical enough place to start inspecting the Ethernaut's Denial contract! There are even comments within the function code to ensure us that the function behaves as expected and could not possibly be exploitable:

```
// withdraw 1% to recipient and 1% to owner
function withdraw() public {
    uint amountToSend = address(this).balance.div(100);
    // perform a call without checking return
    // The recipient can revert, the owner will still get their share
    partner.call{value:amountToSend}("");
    owner.transfer(amountToSend);
    // keep track of last withdrawal time
    timeLastWithdrawn = now;
    withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
}
```

### Always take comments at face value, duh!

Drat! Well, if the comments say the code is bulletproof, it must be true, right? Psh, we know better than that. The function divides the Denial contract's ether balance into 1%:

```address(this).balance.div(100)```

and subsequently sends that amount to the contract's withdrawal partner address from storage and then sends the same amount to the owner of the Denial contract. Knowing that our goal is to prevent this function from being able to complete the 

```owner.transfer(amountToSend)```

line, the clearest way to achieve this would be to set the partner address variable in storage to a malicious contract of our own making and cause any low level ether calls to our malicious contract to revert.

### Not so fast!

But wait! Low level ether calls by definition will never halt execution, regardless of reversion. In fact, wrapping low level ether calls in a higher level assertion has become an important standard for handling errors when writing in Solidity. You've probably seen this Solidity development pattern before; one common implementation of such an assertion might look like this:

```
(bool r,) = partner.call{value:amountToSend}("");
require(r);
```

This way, if the low level ether call reverts for being sent to a non-payable method or a contract without a payable fallback, the require() check will halt execution and refund gas when it would otherwise continue execution despite the low level call's reversion.

### Yes, Solidity is a strange language indeed

So the comments assuring us that the function will move on to the next line and perform the transfer to the owner is at least half correct. Why only 'half correct,' do you ask? There's still one reversion case which has not been handled here. 

Can you guess what it is? Here's a hint: the Ethereum Virtual Machine (EVM) needs a way to prevent permissionless user transactions from eating up all network resources with infinite loops and recursion. This mechanism can be abused here to force a revert even when Ethernaut is using an unchecked low level call!

### GAS

The EVM's gas mechanism protects the network from being dragged into infinite loops, so we could write a malicious contract that uses up all the remaining gas in its fallback! The result? Denial's external call to our malicious 'partner' will never complete with enough gas left to reach and execute the code on line 31!

We've discovered our approach to brick Denial on a high level, so let's implement the griefing hack.




use while loop to consume all gas on unchecked call from instance

takeaway:
check return result on low level call and specify gas amount to forward


○•○ h00t h00t ○•○

