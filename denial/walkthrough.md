# Ethernaut Walkthrough: Denial
## Welcome to KweenBirb's 21st installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Denial.sol, the 21st challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that to beat this level we must 'deny the owner from withdrawing funds when they call withdraw().'



-write malicious contract 
- set as partner 
- use up enough gas on its fallback that line 31 can never execute ?

use while loop to consume all gas on unchecked call from instance

takeaway:
check return result on low level call and specify gas amount to forward


○•○ h00t h00t ○•○

