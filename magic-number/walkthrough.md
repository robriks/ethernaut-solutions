# Ethernaut Walkthrough: Magic Number
## Welcome to KweenBirb's 19th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to MagicNumber.sol, the 19th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file and .yul file in this directory. Let's begin!

In this challenge, Ethernaut describes a deceptively simple objective: deploy a Solver contract that returns the answer to a whatIsTheMeaningOfLife() function call. We all know the answer to such a laughably easy question, and yet we're given a hint:

/*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */

Seems like the easiest Ethernaut challenge ever, right? Not so fast, the contract bytecode needs to be 10 opcodes, maximum. That's a (10) byte-sized contract!

If you've never worked with EVM bytecode directly, fret not for I have included two informative sources in this repo's help.txt file to aid you in understanding the low-level workings of Ethereum. It can sound like a foreign language at first but it'll click once you give yourself some time to visualize the stack.

Onward!

## Working backwards

To figure out how to provide a 10-byte-long, deployed Solver that returns 42, we should work backwards. The opcodes for the equivalent of Solidity's: 

```return (42)``` 

will require us to push a memory slot to the stack, push 2a (42 in hex) to the stack, invoke a memory store, and then return from memory. Something like the following:

```
PUSH 20
PUSH 40
PUSH 2a
DUP2
MSTORE
RETURN
```

Those EVM instructions give us the following runtime bytecode:

```60206040602a8152f3```

So we know what 9 bytes we need to fulfill the proper Solver role for the challenge. Our second objective will be to deploy this bytecode to the protocol. To do so, we first need to understand the difference between contract bytecode and contract initcode. 

The bytecode we decided on above is what we call runtime bytecode, the instructions that will run when a call is made to the deployed contract address. This is different from the bytecode that will actually deploy the contract, which we call initcode.

A contract's initcode will include the runtime bytecode to be stored on chain but will first include instructions that handle the creation of a new contract, namely CREATE or CREATE2. The initcode essentially CODECOPYs the runtime bytecode into memory and then RETURNs, inserting a convenient INVALID (fe) opcode between the initcode and the runtime bytecode to help differentiate between the two.

## From bytecode to Yul assembly

Now that we understand what we need to accomplish to deploy our Solver bytecode, let's back up one layer of abstraction out of EVM opcodes and into Yul assembly! Yul will give us a convenient, very thin wrapper around EVM instructions for us to get our hands dirty in low level code without having to handle each byte individually.

Yul has the added advantage of visually separating initcode from runtime bytecode objects, which will help solidify the concepts we just discussed. We start with a block to deploy the contract:

```
object "contract" {
    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }
}
```

Looks pretty straightforward: we can see that we are copying the size of our "runtime" bytecode from the offset/location of the "runtime" bytecode into memory at slot 0x00. Once that's done, we return the size of our "runtime" bytecode from memory slot 0x00.

All that's left is to define the "runtime" object:

```
object "runtime" {
    code {
        mstore(0x40, 0x2a)
        return(0x40, 0x20)
    }
}
```

## But our solution is not as optimized as our hand-drawn bytecode!

This is the bare minimum yul code necessary to store 0x2a (42) into memory at slot 0x40 and then return 2 bytes from slot 0x40. This should accomplish something very similar to the opcodes we decided on, but you'll notice that it doesn't compile down to exactly the same instructions we chose:

```
"object": "600a600d600039600a6000f3fe602a60405260206040f3",
"opcodes": "PUSH1 0xA PUSH1 0xD PUSH1 0x0 CODECOPY PUSH1 0xA PUSH1 0x0 RETURN INVALID PUSH1 0x2A PUSH1 0x40 MSTORE PUSH1 0x20 PUSH1 0x40 RETURN ",
```

Where our runtime bytecode extracted from within that code looks like this:

```602a60405260206040f3```

It's one byte more than our optimal 9 byte Solver code, but 10 bytes is enough to satisfy the Ethernaut challenge so we're good to go! Perhaps the Yul optimizer will see more improvements in the future to compile down to our handpicked opcodes.

Anyway, all in all, we get the following Yul contract:

```
object "contract" {
    code {
        // deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            mstore(0x40, 0x2a)
            return(0x40, 0x20)
        }
    }
}
```

A successful first foray into EVM bytecode and Yul assembly. 
○•○ h00t h00t ○•○