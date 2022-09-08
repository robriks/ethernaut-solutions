## Welcome to KweenBirb's 7th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Delegation.sol. the 7th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Ethernaut instructs us to defeat this level provided we are simply able to 'claim ownership of the instance you are given.'

We're given two contracts in the source code provided, a Delegation contract that is this level's instance to be exploited and an accompanying Delegate contract that has a single function: pwn(). Interesting.

Since we're l33th4x0rz we know that pwn() will definitely serve the instrumental role in hacking this level, especially considering it sets the address variable in storage to msg.sender.

But pwn() is in the Delegate contract, NOT in the ethernaut instance contract! Guess we'll have to inspect the Delegation contract.

At first glance, we see that like Delegate, Delegation has an owner variable in storage. It also has stored an instance of Delegate, which is utilized in the fallback function:

```
fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
```

The above function uses Solidity's low level delegatecall functionality! That means we should be able to use Delegate's pwn() function to manipulate Delegation's storage variables, like the owner address!

## tiem 2 kode

Let's create a malicious contract with a function that does exactly that. Rather than bother with interfaces, we'll copy paste the source code for our attacker contract, named Delegatoor, to interact with. Therein, we use some low level wizardry:

```
function sendWithData(address $your_ethernaut_address_here) public returns (bool) {
        Delegation delegation = Delegation($your_ethernaut_address_here);
        (bool success,) = address(delegation).delegatecall(abi.encodeWithSignature("pwn()"));
        require(success);
    }
```

## Breaking down the wizardry
Our goal is to trigger Delegation's fallback() function, so we simply call it with some abi encoded msg.data. However, any old msg.data will not do as we need Delegation to pass along said data to Delegate (via delegatecall) and cause pwn() to be called in the context of Delegation's storage.

This means that the msg.data we send to Delegation's fallback must be pwn()'s function selector. Thankfully recent versions of Solidity give us a succinct way of doing so, rather than the old way of typecasting the keccak hash of pwn() into a bytes4- it's done by accessing 


```
abi.encodeWithSignature("pwn()")
```

## Understand, deploy, execute
Make sure the following sentence is fully understood: the function will trigger Delegation's fallback() using pwn()'s function selector as msg.data. This will execute Delegate's logic in the context of Delegation's storage, thereby changing Delegation's owner variable (rather than Delegate's!). 

Yeah, let's reread that a bunch of times because it's a doozy. 

Got it? Good, then we just need to deploy the attacking Delegatoor contract and call our nifty little sendWithData() function to defeat the level.


We just hacked the contract!

h00t h00t
