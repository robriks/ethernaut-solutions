// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GatekeeperOne.sol";

contract Entrant {

    using SafeMath for uint256;

    GatekeeperOne gatekeeperOne;
    
    constructor(address $your_ethernaut_instance_here) public {
      gatekeeperOne = GatekeeperOne($your_ethernaut_instance_here);
    }

    // @param provide the gasAmount that was brute forced by brute-force.js to match the modulused gas amount when reaching gateTwo()
    function breakIn(uint gasAmount) public {
        // derive gateKey by reverse engineering gateThree
        uint64 LEhalf = uint64(uint16(uint160(msg.sender)));
        uint64 REhalf = uint64(bytes8(0x1000000000000000));
        bytes8 gateKey = bytes8(LEhalf + REhalf);
        // leave 8191 gasleft by the time the second modifier is executed
        gatekeeperOne.enter{ gas: gasAmount }(gateKey);
    }
}
