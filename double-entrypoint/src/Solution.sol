// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./DoubleEntrypoint.sol";

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

    function defense() public {
        cryptoVault.sweepToken(legacyToken);
    }
}