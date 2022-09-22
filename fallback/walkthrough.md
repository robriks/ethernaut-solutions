# Ethernaut Walkthrough: Fallback
## Welcome to KweenBirb's 2nd installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Fallback.sol, the 2nd challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Ethernaut instructs us to defeat this level by 'altering the address variable in storage, "owner", to reflect our address so that we may drain the contract's balance.'

Skimming the contract, the withdraw() function stands out as the final step of our exploit, once we've claimed ownership in order to satisfy the onlyOwner() modifier.

Working backwards from there, we notice there are only two ways to alter the owner variable: by using the contribute() function or the receive() fallback. 

In contribute(), the following if clause must be satisfied to set msg.sender as owner:

```
if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
```

Straightforward enough! All we need to do is gain a contribution balance that is greater than that of the current owner, which was set at deployment via the constructor of the contract.

But wait!

We see that the constructor has set a very high bar for the owner/original deployer's contribution value: 1000 ether! We're not nearly whale enough to top that with > 1000 ether, not to mention contribute() restricts your contribution to < 0.001 ether, so let's abandon that approach and examine the receive() fallback instead.

```
receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
```

Here we see a simple check that requires our msg.value to be greater than 0 and to have previously called contribute() to raise our contributions balance above 0. Much easier.

Because the owner variable and contributions mapping will be altered via msg.sender, we will need to defeat this level as an EOA and not with a malicious contract.

Using the browser console, call contribute() with the following javascript snippet:










CHECK THAT THIS IS HOW WEB3 JS  SYNTAX SETS MSG.VALUE IN PAYABLE FUNCTION


```
await contract.contribute({ value: 0.0001 ether })
```

Once we've broadcasted our transaction using metamask and the network has confirmed it, quickly check that the contribution has been updated in the mapping before moving on:

```
await contract.getContribution()
```

Our returned value is indeed 0.0001 so we're halfway to pwntown, frens! All that's left to do is trigger the receive() fallback with some ether so simply grab the ethernaut instance address and send it any amount of ether using MetaMask. To access the instance address, ethernaut has provided a nice shortcut:

```
instance
```

Once the network has successfully confirmed that we sent the contract some wei, we've become the owner! Double check before we drain the contract:

```
await contract.owner()
```

Now that we pwned the contract let's extract the balance that is rightfully ours!

```
await contract.withdraw()
```

And so we've defeated the level and can submit the instance. EZPZ.

○•○ h00t h00t ○•○