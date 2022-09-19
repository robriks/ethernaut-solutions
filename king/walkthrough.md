# Ethernaut Walkthrough: King
## Welcome to KweenBirb's 10th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to King.sol, the 10th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in this directory. Let's begin!

In this challenge, Ethernaut describes a cute little code game of Napoleonic nature: a smart contract that awards kingship to whomever bribes it with the largest running amount of Ether. That is, until the game ends at which point the level simply kings itself. A rigged ponzi game of greater fool theory! We're lightheartedly instructed as follows:

'Such a fun game. Your goal is to break it.'

Ominous, yet inevitable. That is how all ponzi games ultimately end, after all! 👀 Looking at you, US social security 👀

Anyh00t, seeing as our objective is to prevent the level's Napoleonic self-proclamation of kingship at the game's conclusion, we can infer that the level will have to invoke the receive() function and become king via the following line:

```king = msg.sender;```

That means the exploit to break this contract must be before that line of code, preferably some sort of external call as that's our best chance of triggering unexpected behavior.

What do you know, there's an external call (of sorts) in the line preceding:

```king.transfer(msg.value);```

So all we have to do is cause a revert() every time that line executes! Ethernaut even gives us a hint of how to do so by putting this Napoleonic ponzi game inside a payable receive() function. 

Let's say we were to set the storage variable king to be a malicious smart contract of our own creation that doesn't possess a payable receive() (or fallback()) function. Such a smart contract would be incapable of receiving Ether and therefore revert any incoming transaction with msg.value > 0. This is exactly what we're looking for! 

In this scenario, the Napoleonic ponzi would be entirely broken as the msg.value transfer to the king address would be met with a contract where there is no receive() or fallback() function explicitly marked payable. Guaranteed reversion, every time.

So let's do it!

```
interface King {
    function prize() external view returns (uint);
}

contract NapoleonSucks() {

    King king;
    uint bribe;

    constructor(address $your_ethernaut_instance_here) payable {
        
        king = King($your_ethernaut_instance_here);
        bribe = king.prize()++;
        $your_ethernaut_instance_here.call{ value: bribe }();
    }

    fallback() {
        // rekt
    }
}
```

Cool, that was easy. Moving on!
