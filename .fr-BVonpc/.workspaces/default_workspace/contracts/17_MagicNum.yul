// //SPDX-License-Identifier: None
// pragma solidity ^0.8.0;

// contract ByteDeployer {

//     address currentImpl;

//     // _code = 0x602a50
//     function deploy(bytes memory _code) public returns (address) {
//         address deployed;
//         assembly {
//             mstore(0x80, _code)
//             deployed := create(0, 0x80, calldatasize())
//         }
//         currentImpl = deployed;
//         return deployed;
//     }

//     function whatIsTheMeaningOfLife() public returns (uint) {
//         currentImpl.call(abi.encodeWithSignature('whatIsTheMeaningOfLife()'));
//     }
// }

object "42" {
    code {
        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }
    
    object "runtime" {
        code {
                mstore(0x80, 0x2a)
                let x := mload(0x80)
                return(x)
        }
    }
}

// PUSH1 0x2a // 60 2a
// POP // 50
// RETURN // F3