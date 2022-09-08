use custom error injection to spoof a specific error, "NotEnoughBalance()" to the GoodSamaritan contract's requestDonation() function in order to trick it into hitting the catch {} block. This calls transferRemainder(msg.sender) and drains the GoodSamaritan even when its balance is not actually low.

-need to return "NotEnoughBalance()" error to wallet.donate10(msg.sender) call
    -donate10 will hit else {} block and thereby coin.transfer(dest_, 10)
    -coin.transfer() call reverts unless balances[msg.sender] > 10, but msg.sender is the wallet contract in this context so it's fine
        -balances[] will be updated accordingly, and seeing as dest_.isContract() will be true as it will be our malicious contract:
            -INotifyable(dest_).notify() will be called. This is where we inject a reversion to bubble up all the way back to GoodSamaritan and drain the contract.