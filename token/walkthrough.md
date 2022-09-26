# Ethernaut Walkthrough: Token
## Welcome to KweenBirb's 6th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Token.sol, the 6th challenge in the series. You can find the challenge itself in the .txt file in this directory. Let's begin!

In this challenge, Ethernaut describes a basic token of which you've been given 20 units and then cutely declares 'you will beat the level if you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.'

Looking over the code, we notice two things:
1. A lack of either the SafeMath library or a Solidity version > 0.8.0, which means possible underflow/overflow!
2. A lack of custom logic in the token's transfer() function to prevent underflow/overflow

In short, this contract is hella vulnerable to basic arithmetic underflow/overflow. Great!

## Wrap that sucker down and around

You might be tempted to just quickly throw an underflow transfer() to yourself at the contract in javascript, which would be very convenient! Unfortunately that'll just leave you with the same balance you started at, so we'll need to involve a separate address. Literally any address will do, so let's just use the instance contract that Ethernaut has conveniently made available in the javascript console.

```await contract.transfer(instance, 21)```

That's it! Once our transaction is confirmed, we've overflowed the Token instance's uint recordkeeping in its mapping and we know possess 2^256 - 1 tokens. Feel free to admire wealth beyond all measure:

```await contract.balanceOf(player)```

Short and simple. Gotta love it. Always use SafeMath or Solidity version > 0.8.0!

○•○ h00t h00t ○•○
