// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./GatekeeperTwo.sol";

contract EntrantTwo  {
    
    GatekeeperTwo gatekeeperTwo;

    constructor(address $your_ethernaut_instance_here) {
        gatekeeperTwo = GatekeeperTwo($your_ethernaut_instance_here);
    }

    constructor() public {
        goTwo();
    }

    function goTwo() public {
        bytes8 gateKey = bytes8((uint64(0) -1) ^ uint64(bytes8(keccak256(abi.encodePacked(address(this))))));

        gatekeeperTwo.enter(gateKey);
    }

    function test() public pure returns (bytes8) {

        // Manual work shown below to help wrap my mind around the solution

        // (uint64(0) - 1) = 18446744073709551615

        // (keccak256(abi.encodePacked(msg.sender))) = 0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229
        // bytes8((keccak256(abi.encodePacked(msg.sender)))) = 0x5931b4ed56ace4c4
        // uint64(bytes8((keccak256(abi.encodePacked(msg.sender))))) = 6427117074688828612
        
        // 6427117074688828612 ^ uint64(_gateKey) = 18446744073709551615
        
        // Since the inverse of XOR is XOR itself, reverse of above equation is:
        // uint64(_gateKey) = 6427117074688828612 ^ 18446744073709551615
        // uint64(_gateKey) = 12019626999020723003
        // bytes8 _gateKey = 0xa6ce4b12a9531b3b
        return bytes8(uint64(12019626999020723003));
    }
}