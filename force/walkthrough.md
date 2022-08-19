## Welcome to KweenBirb's 7th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to the 7_Force.sol challenge. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that 
### 'the goal of this level is to make the balance of the contract greater than zero.'

And yet, the source code for the contract is entirely empty, save for a cute ascii art rendition of a cat inquisitively meowing at you. All in comments, of course.

So, since there's no receive() or fallback() function to accept ether, how are you supposed to raise the balance of this contract above 0?


selfdestruct()





Fun fact: Vitalik Buterin has been loudly clamoring for the selfdestruct() opcode to be eliminated from Solidity for a while now! It's possible that this challenge is eventually rendered irrelevant, but for now it's a fun little trick.