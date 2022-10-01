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

If you recall what we learned in Ethernaut's Magic Number challenge, there are two kinds of contract bytecode: initcode and runtime bytecode. It so happens that during the deployment of a smart contract, ie while initcode is being run, the runtime bytecode has not yet been deployed to the chain. This means that a contract's EXTCODESIZE() is 0 during the execution of initcode, known in Solidity as a constructor() function.

So this second gate modifier can be bypassed so long as we call into GatekeeperTwo's enter() function in the same transaction while our contract is being deployed during its constructor.

## The gateThree() modifier







// (uint64(0) - 1) = 18446744073709551615

// (keccak256(abi.encodePacked(msg.sender))) = 0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229
// bytes8((keccak256(abi.encodePacked(msg.sender)))) = 0x5931b4ed56ace4c4
// uint64(bytes8((keccak256(abi.encodePacked(msg.sender))))) = 6427117074688828612

// 6427117074688828612 ^ uint64(_gateKey) = 18446744073709551615

// Since the inverse of XOR is XOR itself, reverse of above equation is:
// uint64(_gateKey) = 6427117074688828612 ^ 18446744073709551615
// uint64(_gateKey) = 12019626999020723003
// bytes8 _gateKey = 0xa6ce4b12a9531b3b


○•○ h00t h00t ○•○