# Ethernaut Walkthrough: Fallout
## Welcome to KweenBirb's 3rd installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a quick solution to Fallout.sol, the 3rd introductory challenge in the series. You can find the challenge itself and fully fleshed out solution in this directory's .txt file. Let's begin!

Looking over the contract, we're presented with a few methods: one to view an address's allocations mapping value which appears to track user balances, one to add to a user's allocations, one to reclaim a user's allocated balance, and one permissioned method to rug pull the contract's balance. Fine and dandy.

## Constructor quirks

Aside from the allocations logic, two things stand out here, the first being an outdated syntax for the contract constructor. Usually, a contract's initcode for deployment is specified using the ```constructor() {}``` keyword but it can also be done by giving a capitalized function name that matches the contract name. The second is the header image for this level that matches the contract/constructor function name. Or does it?

![image](fal1out.svg)

Do you see it? There's a typo in the constructor function name 🤦🤦🤦 The constructor was never run and it's now a callable public function. Easy way to become owner, lol.

```await contract.fal1out()```

Silly, I know. But there have been instances of contract typos leading to unfortunate situations on-chain. Smart contract development is dangerous after all, simple typos and logic mistakes can lead to large losses of funds.

Be careful out there!!!

○•○ h00t h00t ○•○