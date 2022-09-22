# Ethernaut Walkthrough: Alien Codex
## Welcome to KweenBirb's 20th installment of Ethernaut walkthroughs!
Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to AlienCodex.sol, the 20th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that we've found an Alien contract and must 'claim ownership to complete the level.'

Interesting, yet a simple prompt: the contract gives us a way to tabulate any contact with alien species as well as record, retract, and revise relevant entries in a codex. There isn't even a storage address variable named owner declared in this contract for us to interact with! Ownership is handled by the imported inheritance of Ownable.sol. Tricky!

Glancing over the contract at hand, we can however see some logic of interest in the revise() function: a bytes32 parameter passed in and then used to reassign a value within the dynamic bytes32[] array in storage: codex[]. Knowing that working with dynamic bytes arrays can be dangerous, especially when writing to storage and accepting unrestricted bytes parameters, that'll definitely be our best shot at hacking this codebase.




storage slots;
0: contact bool value concatenated w/ owner address (via ownable import)
1: codex.length (array length of dynamic byte array codex[])
keccak256(1): codex[] array

Solidity compiler (pre 0.6.0) checks indices provided to byte arrays: 
if i > array.length revert()

But it doesn't prevent under/overflow (pre 0.8.0), so for :
array.length == 0; 
array.length--; // ( == 2**256 - 1 )

Which allows you to use the bytes array to reach into ANY storage slot and thereby manipulate any storage value of the contract
Provided that the array given starts at 

arrayLengthSlot = 1;
arraySlot = keccak256(arrayLengthSlot);

a hacker is able to manipulate the value of the contract owner by reaching over to storage slot 0 from arraySlot, using twos complement to overflow back to 0:

zeroSlot = 2**256 - arraySlot
bytes32 caller = bytes32(bytes20(msg.sender))
contract.revise(zeroSlot, caller)


○•○ h00t h00t ○•○

