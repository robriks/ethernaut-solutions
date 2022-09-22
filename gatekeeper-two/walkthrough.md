# Ethernaut Walkthrough: Gatekeeper Two
## Welcome to KweenBirb's 15th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GatekeeperTwo.sol, the 15th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Just like the previous Gatekeeper challenge, Ethernaut again instructs us to 'register as an entrant to pass this level.' This time with a few different kinks to work out, first.



// (uint64(0) - 1) = 18446744073709551615

// (keccak256(abi.encodePacked(msg.sender))) = 0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229
// bytes8((keccak256(abi.encodePacked(msg.sender)))) = 0x5931b4ed56ace4c4
// uint64(bytes8((keccak256(abi.encodePacked(msg.sender))))) = 6427117074688828612

// 6427117074688828612 ^ uint64(_gateKey) = 18446744073709551615

// Since the inverse of XOR is XOR itself, reverse of above equation is:
// uint64(_gateKey) = 6427117074688828612 ^ 18446744073709551615
// uint64(_gateKey) = 12019626999020723003
// bytes8 _gateKey = 0xa6ce4b12a9531b3b


○•○ h00t h00t ○•○