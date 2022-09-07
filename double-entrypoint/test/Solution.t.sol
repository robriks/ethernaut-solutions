// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/DoubleEntrypoint.sol";

contract DefenseTest is Test {

    uint rinkebyFork;
    string RINKEBY_RPC_URL = vm.envString("RINKEBY_RPC_URL");

    function setUp() public {
        rinkebyFork = vm.createFork(RINKEBY_RPC_URL);
    }

    function testVulnerability() public {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        // set rinkebyFork address values
        Forta forta = Forta(0x4696ABBC28BFE5DE5Bdbd9927D580a771104410c);
        DoubleEntryPoint instance = DoubleEntryPoint(0xDCf7c4A90d30bd91a103436aEa1130fe829D284f);
        CryptoVault vault = CryptoVault(0x6AC0adC52258974076F6169104859b6626954554);
        LegacyToken LGT = LegacyToken(0xfB4880DD9Fb04f86D1f88Bb4D4C6e792c265c071);
        
        // deploy
        DetectionBot detectionBot = new DetectionBot(
            address(forta), 
            address(instance),
            address(vault),
            address(LGT)
        );

        uint a = detectionBot.proveVulnerability();
        assertEq(a, 0);
    }

    function testDefense() public returns (bytes memory) {
        vm.selectFork(rinkebyFork);
        assertEq(vm.activeFork(), rinkebyFork);

        // set rinkebyFork address values
        Forta forta = Forta(0x4696ABBC28BFE5DE5Bdbd9927D580a771104410c);
        DoubleEntryPoint instance = DoubleEntryPoint(0xDCf7c4A90d30bd91a103436aEa1130fe829D284f);
        CryptoVault vault = CryptoVault(0x6AC0adC52258974076F6169104859b6626954554);
        LegacyToken LGT = LegacyToken(0xfB4880DD9Fb04f86D1f88Bb4D4C6e792c265c071);
        
        // deploy
        DetectionBot detectionBot = new DetectionBot(
            address(forta), 
            address(instance),
            address(vault),
            address(LGT)
        );

        vm.prank(0x5d5d4d04B70BFe49ad7Aac8C4454536070dAf180);
        forta.setDetectionBot(address(detectionBot));
        vm.expectRevert(bytes("Alert has been triggered, reverting"));
        detectionBot.defense();
    }
}

contract DetectionBot is IDetectionBot {

    Forta forta;
    DoubleEntryPoint doubleEntryPoint;
    CryptoVault cryptoVault;
    LegacyToken legacyToken;

    constructor(
        address $your_Forta_here,
        address $your_ethernaut_instance_here, 
        address $your_CryptoVault_here, 
        address $your_LegacyToken_here
        ) {
            forta = Forta($your_Forta_here);
            doubleEntryPoint = DoubleEntryPoint($your_ethernaut_instance_here);
            cryptoVault = CryptoVault($your_CryptoVault_here);
            legacyToken = LegacyToken($your_LegacyToken_here);
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        require(msg.sender == address(forta), 'Must be called by Forta contract');
        
        // calldata layout IN THIS TX CONTEXT: bytes4 funcSig:(handleTransaction) / bytes32 address:(user) + bytes100[bytes4 funcSig:(delegateTransfer) / bytes32 address:(to) / bytes32 uint:(value) / bytes32 address:(origSender)]
        // ie:
        // 0x220ab6aa0000000000000000000000005d5d4d04b70bfe49ad7aac8c4454536070daf18000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000064
        // then the appended bytes calldata parameter msgData:
        // 0x9cd1a1210000000000000000000000005d5d4d04b70bfe49ad7aac8c4454536070daf1800000000000000000000000000000000000000000000000056bc75e2d631000000000000000000000000000006ac0adc52258974076f6169104859b6626954554
        bytes32 res;
        assembly {
            res := calldataload(0xa8)
        }
        if (address(uint160(uint256(res))) == address(cryptoVault)) { 
            forta.raiseAlert(user); 
        }
    }

    function proveVulnerability() public returns (uint) {
        IERC20 underlying = cryptoVault.underlying();
        cryptoVault.sweepToken(legacyToken);
        return underlying.balanceOf(address(cryptoVault));
    }

    // for testing
    function defense() public {
        cryptoVault.sweepToken(legacyToken);
    }
}