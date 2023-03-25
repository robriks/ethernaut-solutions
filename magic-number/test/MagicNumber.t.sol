// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

interface MagicNumber {
    function any() external returns (uint256);
}

contract MagicNumberTest is Test {

    MagicNumber public magicNumber;

    function setUp() public {
       magicNumber = MagicNumber(HuffDeployer.deploy('magicNumber'));
    }

    function testFallbackReturns42(uint256 x) public {
        uint256 fourtyTwo = magicNumber.any();
        assertEq(fourtyTwo, 42);
    }
}
