# Ethernaut Walkthrough: Naughtcoin
## Welcome to KweenBirb's 16th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Naughtcoin.sol, the 16th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in this directory. Let's begin!

In this challenge, Ethernaut describes a locked vesting scenario: being the mysterious shadowy insiders we are, we've been allocated 100% of the Naughtcoin ERC20 supply but cannot move (or dump them on the plebs SBF-style) for 10 years! Our objective is to: 'figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.'

## The ERC20 spec

If you're familiar with the ERC20 spec, this challenge will be very simple to complete. That also applies if you're familiar with the ERC721 spec! In fact, chances are that if you've completed pretty much any kind of token swap or interacted with a protocol developed for the ERC20, ERC721, or ERC1155 standards, you know exactly what needs to be done to complete this challenge. Do you see where I'm going with this?

That's right, there are two separate ways to transfer tokens when using those specs. As you probably noticed while looking over Naughtcoin's lockTokens modifier, only one transfer method is blocked:

```
// Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(now > timeLock);
      _;
    } else {
     _;
    }
  }
```

This modifier is applied to the ERC20 spec's transfer() function, which is called by the owner of the token and a 'to' parameter is given to complete the transfer. But this modifier is not added to the ERC20 spec's transferFrom() function, which is frankly even more common when handling fungible and nonfungible tokens as it is the function that allows external smart contracts to transfer tokens on behalf of EOA users. You've almost certainly signed txs with this function signature if you've used any Ethereum protocol.

So all we have to do is call that function! But first we must consent to those tokens being transferred on our behalf. Even when being naughty, consent is still sexy after all!

```
// this function assumes the hacker/deployer of this contract has already called approve for their vested/locked tokens on the target contract
function naughtyConsent() public {
    uint amount = naughtCoin.balanceOf(hacker);
    naughtCoin.transferFrom(hacker, address(this), amount);
}
```

Since we need to provide the address of the our malicious hacker contract as a parameter to the ERC20 approve() function, we first deploy the malicious contract containing the function above. Then we grab its address and load it into Ethernaut's handy js console:

```
const maliciousContract = '$your_naughty_hacker_contract_here'
// player is an accessible variable provided by Ethernaut by default
const amount = await contract.balanceOf(player) 

await contract.approve(maliciousContract, amount)
```

Once the approve transaction is mined by the network, simply call the naughtyConsent() function we wrote on our malicious hacker contract to drain our balance without even touching the lockTokens() modifier!

h00t h00t! Get dumped on 😈 😈 😈 