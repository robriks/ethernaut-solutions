# Ethernaut Walkthrough: Good Samaritan
## Welcome to KweenBirb's 28th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GoodSamaritan.sol, the 28th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in the ./src directory. Let's begin!

In this challenge, Ethernaut describes a generous philanthropist who has written a contract that dispenses tokens to any poor soul destitute enough to request some. It is of course hinted that we are 'able to drain all the balance from his Wallet.'



use custom error injection to spoof a specific error, "NotEnoughBalance()" to the GoodSamaritan contract's requestDonation() function in order to trick it into hitting the catch {} block. This calls transferRemainder(msg.sender) and drains the GoodSamaritan even when its balance is not actually low.

-need to return "NotEnoughBalance()" error to wallet.donate10(msg.sender) call
    -donate10 will hit else {} block and thereby coin.transfer(dest_, 10)
    -coin.transfer() call reverts unless balances[msg.sender] > 10, but msg.sender is the wallet contract in this context so it's fine
        -balances[] will be updated accordingly, and seeing as dest_.isContract() will be true as it will be our malicious contract:
            -INotifyable(dest_).notify() will be called. This is where we inject a reversion to bubble up all the way back to GoodSamaritan and drain the contract.


○•○ h00t h00t ○•○