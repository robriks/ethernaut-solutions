## Welcome to KweenBirb's 14th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GatekeeperOne.sol, the 14th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Ethernaut here instructs us to 'make it past the gatekeeper and register as an entrant to pass this level.' Sounds simple, but even though the contract is short and sweet we just know it's going to be a doozy.


----create Solution.sol version of Entrant contract

---include screenshot of result from brute-force.js

gate1 gate2 gate3 explanation

1: smart contract that is not user EOA
2: gas consumption brute forcing to identify exact amount of gas to forward // via hardhat js script
3: typecasting the bytes8 parameter _gateKey to get access to Entrant registry // via reverse engineering the key required and then simulating the typecasting. work backwards from nested tx.origin variable