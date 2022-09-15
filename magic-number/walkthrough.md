# Ethernaut Walkthrough: Magic Number
## Welcome to KweenBirb's 19th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to MagicNumber.sol, the 19th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .yul file in the ./src directory. Let's begin!

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

If you've never worked with EVM bytecode directly, fret not for I have included two extremely informative sources in the help.txt file to aid you in understanding the low-level workings of Ethereum. It can sound like a foreign language at first but it won't take long to click and you'll be comfortable with it all of a sudden.

Onward! 

-- evm opcodes needed, discuss stack machine, runtime bytecode vs initcode
    PUSH 20
    PUSH 40
    PUSH 2a
    DUP2
    MSTORE
    RETURN

runtime bytecode: 60206040602a8152f3
initcode:

-- second solution using Yul: discuss yul as assembly language with very little abstraction over evm opcodes

discuss structure of yul contracts (in terms of alrdy discussed initcode, runtime)

note that solution.yul code deploys a contract with different bytecode than what we came up with in the first solution due to lack of optimization
