//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract Guzzler {

    constructor() payable {}

    function coronate(address king) public {
        (bool a,) = payable(king).call{value: address(this).balance }('');
        require(a);
    }
}