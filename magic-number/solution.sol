// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

/*
    EVM instructions needed:

    PUSH 20
    PUSH 40
    PUSH 2a
    DUP2
    MSTORE
    RETURN

    Therefore runtime bytecode:
    
    60206040602a8152f3

    resulting initcode for above runtime bytecode:
    
    (codecopy, return, runtime)
    6009600c600039 60096000f3 60206040602a8152f3
*/

    contract Deployer {
        function deployHack() public {
            address solver;
            assembly {
                mstore(0x00, 0x6860206040602a8152f3600052600d6000f3)
                solver := create(0, 0x00, 0x0a)
            }
        }
    }