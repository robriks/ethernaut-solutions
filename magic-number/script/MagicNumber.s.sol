// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { HuffDeployer } from "foundry-huff/HuffDeployer.sol";

interface MagicNumber {
    function any() external returns (uint256);
}

interface MagicNum {
    function setSolver(address _solver) external;
}

contract MagicNumberHuffScript is Script {

    function run() public {
        // use HuffDeployer plugin to deploy huff contracts
        vm.allowCheatcodes(0xB5AED9E9CFd2f09b4bDE154d806dCA427F24cCa4);
        address huffContract = HuffDeployer.broadcast('magicNumber');

        // MagicNumber magicNumber = MagicNumber(huffContract);
        // set Ethernaut's MagicNum contract storage address solver to our huff contract for submission
        uint256 deployerPK = vm.envUint("PK");
        MagicNum $your_ethernaut_address_here = MagicNum(vm.envAddress("TARGET"));

        vm.startBroadcast(deployerPK);
        $your_ethernaut_address_here.setSolver(huffContract);
        vm.stopBroadcast();
    }
}
