# Ethernaut Walkthrough: Double Entrypoint
## Welcome to KweenBirb's 27th installment of Ethernaut walkthroughs!
Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to DoubleEntrypoint.sol, the 27th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that this time, rather than just hack the contracts using a clever exploit, we must also work defensively to 'figure out where the bug is in CryptoVault and protect it from being drained out of tokens.' Time to put away the black hat and replace it with a white one!

First things first: Ethernaut tells us to 'figure out where the bug is in CryptoVault' so that's where we'll begin.

```
contract CryptoVault {
    address public sweptTokensRecipient;
    IERC20 public underlying;

    constructor(address recipient) public {
        sweptTokensRecipient = recipient;
    }

    function setUnderlying(address latestToken) public {
        require(address(underlying) == address(0), "Already set");
        underlying = IERC20(latestToken);
    }

    /*
    ...
    */

    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
    }
}
```

Only a few lines of code to look at! And much of it is not relevant to any potential bugs: the constructor sets the public storage address sweptTokensRecipient and the setUnderlying() function stores the underlying IERC20 in storage, with the caveat that it may only be set once. If setUnderlying() hasn't been called yet to set the IERC20 in storage, that'd be an easy way to inject malicious code. 

## Let's check!

First we set some bash environment variables from our end for Foundry to utilize:

```
export PRIVATE_KEY=$your_private_key_here
export RPC_URL=$your_rpc_endpoint_such_as_infura_here
export INSTANCE=$your_ethernaut_instance_here
```

Then we grab some environment variables from Ethereum's end wrt the Ethernaut instance:
(The shl is only there as a lazy way to typecast bytes32 to address by removing leading zeroes)

```
VAULT=$(cast shl $(cast call $INSTANCE --rpc-url $RPC "cryptoVault()") 0)
LEGACY=$(cast shl $(cast call $INSTANCE --rpc-url $RPC "delegatedFrom()") 0)
FORTA=$(cast shl $(cast call $INSTANCE --rpc-url $RPC "forta()") 0)
```

Then we check to see if underlying is already set:

```cast call $VAULT --rpc-url $RPC "delegate()"```

Drat! It's been set, no free lunch today. That leaves sweepToken(), and since we're looking to protect this contract from being drained, that was most likely the exploitable function anyway.

## An external call!

The sweepToken() function seems bulletproof, but we've eliminated every other potential source of the bug so we know it must be in there somewhere. It does involve an external call, which we know to often be an attack vector:

```token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));```

The transfer() function gets called on any IERC20 compliant contract we want, since sweepToken() has public visibility. So in theory we could make a malicious contract with an overridden transfer() function so that it... wait a second! There's already an ERC20 contract here that in the codebase that overrides transfer()!

## Let's have a look at LegacyToken

We've established that the CryptoVault contract appears to be designed to be called by a regular ERC20 contract without heavy modifications, though it will accept modified ERC20s. The code provided for the LegacyToken contract overrides the transfer() function inherited from OpenZeppelin's ERC20 parent implementation:

```
function transfer(address to, uint256 value) public override returns (bool) {
    if (address(delegate) == address(0)) {
        return super.transfer(to, value);
    } else {
        return delegate.delegateTransfer(to, value, msg.sender);
    }
}
```

That tells us invoking CryptoVault's sweepToken() with the LGT contract as a parameter causes the ```token.transfer()``` call to select LGT's transfer() function instead of its parent ERC20 transfer() method. When the overridden transfer() function is called, we're presented two execution options, the LGT token will either:
1. transfer() its own tokens if no DelegateERC20 storage delegate is set 
   OR 
2. delegateTransfer() delegate's tokens if DelegateERC20 storage delegate is already set

So we identify which option is executed by checking the DelegateERC20 in storage:

```cast call $LEGACY --rpc-url $RPC "delegate()"```

And note that one is indeed set. So the second option will be taken, invoking the ```delegateTransfer()``` function in DoubleEntryPoint and thereby draining the vault's entire DET balance by sending it to the vault's storage address, sweptTokensRecipient.

## Time for Triage

Thankfully the delegateTransfer() function in DoubleEntryPoint has a fortaNotify modifier that will give us the opportunity to swoop in and save the contract from thieving attackers. Our objective now is to write a handleTransaction() function that blocks the bug we identified from being exploited.

To protect against the exploit, we must implement a protective DetectionBot contract with a handleTransaction() function that will prevent delegateTransfer() from being called with the CryptoVault address as its origSender address parameter. That way, when the fortaNotify() modifier of DET's delegateTransfer() is run, Forta will be notified and in turn call our DetectionBot's handleTransaction() where we can save the day!

The IDetectionBot interface gives us a simple framework to start with, accepting the msg.data of the current context as a parameter to parse and intervene if need be. To do so, let's first examine the bytes calldata msgData passed to Forta in the notify call:

```0x9cd1a1210000000000000000000000005d5d4d04b70bfe49ad7aac8c4454536070daf1800000000000000000000000000000000000000000000000056bc75e2d631000000000000000000000000000006ac0adc52258974076f6169104859b6626954554```

In the msg.data above, we can see:
1. Function selector 0x9cd1a121 which is the keccak256 hash of 'delegateTransfer(address,uint256,address)'
2. Our Ethernaut player address (whoops, doxed! lol) which in this case was passed along to delegateTransfer() having come all the way from storage address sweptTokensRecipient in the CryptoVault contract
3. The value parameter that like our player address was set way back in the CryptoVault context and has now been passed to delegateTransfer
4. The CryptoVault contract address (that was/will be set in the constructor as $your_ethernaut_instance_here) which in this scenario serves as delegateTransfer's origSender parameter or in ERC20 terms, the owner from which the tokens are being transferred
   
In order to defend CryptoVault against this exploit, the fourth item located at position 0xa8 near the end of the calldata is what we're interested in blocking. 

```
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
```

And there we have a cute little bot to protect the CryptoVault from being drained.

All that's left to do to save this poor contract from dangerous hackers in the dark forest is call setDetectionBot() on the Forta contract, providing the deployed defensive DetectionBot address, christening it ardent warden of the CryptoVault. Don't forget to do it manually via EOA, as the Forta contract will read and store msg.sender on the tx.

○•○ h00t h00t ○•○