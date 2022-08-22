// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

/*
    EVM instructions:

    PUSH 20
    PUSH 40
    PUSH 2a
    DUP2
    MSTORE
    RETURN

    bytecode:

    60206040602a8152f3
*/

    contract Deployer {
        function deployHack() internal override {}
    }