# Ethernaut Walkthrough: Vault
## Welcome to KweenBirb's 9th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Vault.sol, the 9th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in this directory. Let's begin!

In this challenge, Ethernaut provides us with only one sentence: 'Unlock the vault to pass the level!'

Inspecting the contract, we see two storage variables: a public boolean named locked and a private bytes32 named password. The password is used in the unlock() function to check if the input calldata matches the password, which unlocks the contract by flipping locked:

```
function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
}
```

Nifty way to lock and unlock a smart contract vault, right? WRONG! We know for a fact that nothing on-chain is private- everything is public to ensure auditability and transparency while we figure out how to enshrine zero knowledge proofs like zk-snarks into the protocol. So our objective is to access the private bytes32 password from this instance's storage layout.

## Using Foundry to inspect storage layout

While Solidity will block us from accessing private password variables, off-chain languages face no such obstacles. While this level is of course doable in Javascript, the best and most powerful tool for this sort of work is hands down Paradigm's Foundry. Let's get started.

First, install and initialize a Foundry repo:

```forge init```

Feel free to hit up to the Foundry book if you need to reference documentation:

https://book.getfoundry.sh/

Now we can use Foundry's awesome power to obtain the Vault contract's password! But first we need to know exactly where to look, so let's go back to looking at Vault's storage layout. There are two storage variables that we pointed out earlier, but since contract storage will pack smaller data into 32 byte units to save on gas we have to account for that.

The first storage variable is a boolean, which of course is the smallest Solidity type. There's a good chance this would get packed with whatever storage variable falls next in declaration- however in this case, the second storage variable is our bytes32 password. A bytes32 variable will occupy an entire storage slot, meaning that the locked boolean is occupying a slot all on its own here. It's worth nothing that storage slots begin at 0, not 1. This means that the locked boolean resides in storage slot 0 with a bunch of empty bytes, and the password bytes32 takes up the entirety of storage slot 1.

We can check our musings using Foundry's cast storage tool as follows:

```cast storage --rpc-url $RPC $your_ethernaut_instance_here 0```

Where the --rpc-url flag is an RPC endpoint used to make calls to an Ethereum node. I like using Infura for this, but Alchemy is another popular option and Coinbase Cloud just recently added convenient RPC API keys for developers to use! Anyway, That should give us the value of the locked boolean, which returns 0x01 (ie true) as expected! Then we follow up with a second check:

```cast storage --rpc-url $RPC $your_ethernaut_instance_here 1```

Which will give us the data that resides in Vault's second storage slot: password. Perfect! We've exposed the Vault's bytes32 password and can now call the unlock() function using it as our calldata parameter.

```await contract.unlock($your_exposed_vault_password)```

Just like that, we've completed the level. Never. Store. Anything. Sensitive. On. Chain. Unless you've hashed it with solid cryptography ;)

Welcome to being Foundry-pilled, anon.

○•○ h00t h00t ○•○
