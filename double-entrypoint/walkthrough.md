Forta allows users to set their own detection bots with custom handleTransaction() implementations
-i think handleTransaction() will also handle notifying users of unexpected activity?
-keeps a counter of alerts raised in order to revert unsavory transactions

find bug in cryptoVault:
cryptoVault is minted 100 DET tokens / 100 LGT tokens
DET token is underlying
-can use sweepToken to send entire balance of all tokens exceptone: IERC20 storage underlying
-doesnt look like underlying can be reset after it's set the first time

LGT token will either:
1. transfer() its own tokens if no DelegateERC20 storage delegate is set 
   OR 
2. delegateTransfer() delegate's tokens if DelegateERC20 storage delegate is set
delegate appears to only be manipulable by onlyOwner()

DET token will only allow its balance to be transferred by the LGT contract
- checks for any botRaisedAlerts from the ethernaut player's detectionBots: if any alerts are raised&added to the counter, transfer is reverted


The CryptoVault contract appears to be designed to be called by a regular ERC20 contract without heavy modifications. However, since LegacyToken overrides the transfer() function inherited from OpenZeppelin's ERC20 parent implementation, invoking CryptoVault's sweepToken() with the LGT contract as a parameter causes the ```token.transfer()``` call to select LGT's transfer() function instead of its parent ERC20 transfer() method. This in turn passes execution to the ```delegateTransfer()``` function in DoubleEntryPoint and thereby drains the vault of its entire DET balance, sending it to the vault's storage address, sweptTokensRecipient.

To protect against this scenario, we must implement a protective DetectionBot contract with a handleTransaction() function that will prevent delegateTransfer() from being called with the CryptoVault address as its origSender address parameter. That way, when the fortaNotify() modifier of DET's delegateTransfer() is run, Forta will be notified and in turn call our DetectionBot's handleTransaction() where we can save the day!

Whew, okay let's get started by training our lil detectionBoy to be the hackerblocker hero we all deserve. The IDetectionBot interface gives us a simple framework to start with, accepting the msg.data of the current context as a parameter to parse and intervene if need be. To do so, let's first examine the bytes calldata msgData passed to Forta in the notify call:

```0x9cd1a1210000000000000000000000005d5d4d04b70bfe49ad7aac8c4454536070daf1800000000000000000000000000000000000000000000000056bc75e2d631000000000000000000000000000006ac0adc52258974076f6169104859b6626954554```

Nothing too complex in the msg.data above, we can easily see:
1. Function selector 0x9cd1a121 which is of course the keccak256 hash of 'delegateTransfer(address,uint256,address)' followed by 
2. Our Ethernaut player address which in this case was passed along to delegateTransfer() having come all the way from storage address sweptTokensRecipient in the CryptoVault contract
3. The value parameter that like our player address was set way back in the CryptoVault context and has now been passed to delegateTransfer
4. The CryptoVault contract address (that was/will be set in the constructor as $your_ethernaut_instance_here) which in this scenario serves as delegateTransfer's origSender parameter or in ERC20 terms, the owner from which the tokens are being transferred.
   
In order to defend CryptoVault against this exploit, the fourth item located at position 0xa8 near the end of the calldata is what we're interested in blocking. 

function handleTransaction(address user, bytes calldata msgData) external {
        require(msg.sender == address(forta), 'Must be called by Forta contract');
        
        bytes32 res;
        assembly {
            res := calldataload(0xa8)
        }
        if (address(uint160(uint256(res))) == address(cryptoVault)) { 
            forta.raiseAlert(user); 
        }
    }

And there we have a cute little bot to protect the CryptoVault from being drained.

All that's left to do to save this poor contract from dangerous hackers in the dark forest is call setDetectionBot() on the Forta contract, providing your deployed defensive DetectionBot address, christening it ardent warden of the CryptoVault. Be sure to do it manually via EOA, as the Forta contract will read and store msg.sender on the tx.
