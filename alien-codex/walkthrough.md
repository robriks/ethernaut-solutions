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
