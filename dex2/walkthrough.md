## Welcome to KweenBirb's 24th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to DexTwo.sol, the 24th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that, much like the previous level named Dex, we 'need to drain all balances of token1 and token2 from the DexTwo contract to succeed in this level.' This time, however, the contract is slightly modified in such a way that our exploit will require a different approach.



unlike previous ethernaut level dex, swap function no longer requires set token1 and token2 addresses! This gives us an additional attack vector to the previous economic liquidity attack we executed on dex1: a spoofed contract code injection opportunity!

let's create a custom malicious token to provide unexpected erc20 values to dex contract and drain both sides of the liquidity pool

suggestions for improvement: rather than invoking IERC20() calls on the provided parameters: address from, address to; simply anchor those calls to the storage variables: address token1, address token2.
