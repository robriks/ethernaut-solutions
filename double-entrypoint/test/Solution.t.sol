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

        forta.setDetectionBot(address(detectionBot));
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
            doubleEntryPoint = DoubleEntryPoint($your_ethernaut_instance_here);
            cryptoVault = CryptoVault($your_CryptoVault_here);
            legacyToken = LegacyToken($your_LegacyToken_here);
    }

    function handleTransaction(address user, bytes calldata msgData) external returns (bytes calldata) {
        require(msg.sender == address(forta));
        // bytes memory data = msgData;
        assembly {
            mstore(0x00, msgData)
            
        }
    }

    function proveVulnerability() public returns (uint) {
        IERC20 underlying = cryptoVault.underlying();
        cryptoVault.sweepToken(legacyToken);
        return underlying.balanceOf(address(cryptoVault));
    }

    function defense() public {
        cryptoVault.sweepToken(legacyToken);
    }
}