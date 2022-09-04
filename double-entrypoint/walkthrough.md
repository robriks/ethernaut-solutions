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

DET token will only allow its balance to be transfered by the LGT token
- checks for any botRaisedAlerts from the ethernaut player's detectionBots: if any alerts are raised&added to the counter, transfer is reverted
