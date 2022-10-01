# Ethernaut Walkthrough: Gatekeeper Two
## Welcome to KweenBirb's 15th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GatekeeperTwo.sol, the 15th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Just like the previous Gatekeeper challenge, Ethernaut again instructs us to 'register as an entrant to pass this level.' This time with a few different kinks to work out, first.

## The gateOne() modifier

The first gate modifier is identical to that of the previous challenge:

```
modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
}
```

All it does is ensure that an external caller of the enter() function is not an EOA but instead a smart contract.

## The gateTwo() modifier

The second gate modifier introduces a very brief assembly block. Within the assembly, we note an invocation of the EXTCODESIZE opcode. This opcode returns the size of the runtime bytecode that resides at a given address, in this case Yul's caller() function which is equivalent to Solidity's msg.sender variable.

```
modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
}
```

... What? See that? It's assigning the EXTCODESIZE() of the function caller, which we know must be a smart contract due to the gateOne() modifier. But how can the EXTCODESIZE() of a contract that has enough code to call this function be 0? Doesn't the sole fact that a smart contract is calling this function mean its EXTCODESIZE() must be > 0?

Not exactly. There is a moment in time during execution where  a smart contract's EXTCODESIZE() can be 0 despite it possessing code. Can you guess when that might be?

If you recall what we learned in Ethernaut's Magic Number challenge, there are two kinds of contract bytecode: initcode and runtime bytecode. It so happens that during the deployment of a smart contract, ie while initcode is being run, the runtime bytecode has not yet been deployed to the chain. This means that a contract's EXTCODESIZE() is 0 during the execution of the initcode, known in Solidity as a constructor() function.

So this second gate modifier can be bypassed so long as we call into GatekeeperTwo's enter() function in the same transaction that deploys our contract- during its constructor.

## The gateThree() modifier

Okay, onto the elephant in the room- what the fuck is this:

```
modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
}
```

Aside from being some unrealistic monstrosity that you'd never see in the wild, it's not actually as bad as it looks. Let's start with the innermost items and work outward.

```abi.encodePacked(msg.sender)```

To start, the gateThree modifier uses the caller address to derive the  _gateKey that we need to will register as an entrant. It's then hashed:

```keccak256(abi.encodePacked(msg.sender))```

and typecast into a uint64:

```uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))```

which is then XORed against the _gateKey bytes8 parameter provided:

```uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey)```

And that result is checked within a require() statement against ```uint64(0) - 1``` which due to underflow is equivalent to 18446744073709551615. As of Solidity 0.8.0 this can also be accessed with ```type(uint64).max```

```
require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
```

## Crafting a function to slip past the gateThree() modifier

Great! Now that we understand gateThree(), our goal is to reverse engineer this process and provide the correct bytes8 _gateKey parameter we do the steps outlined above in reverse, providing the address of our contract using ```address(this)```

Keep in mind that the inverse of XOR is XOR itself!

```
function slipInside() public {
    bytes8 gateKey = bytes8((uint64(0) -1) ^ uint64(bytes8(keccak256(abi.encodePacked(address(this))))));

    gatekeeperTwo.enter(gateKey);
}
```

## GateTwo must be satisfied

And don't forget to call our function in the constructor to make sure it passes the EXTCODESIZE check in the gateTwo() modifier!

```
constructor(address $your_ethernaut_instance_here) {
    gatekeeperTwo = GatekeeperTwo($your_ethernaut_instance_here);
    slipInside();
}
```

Using the constructor on deployment of our contract, we've slipped inside the GatekeeperTwo contract to register as an EntrantTwo. Success!

○•○ h00t h00t ○•○