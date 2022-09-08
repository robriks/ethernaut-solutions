## Welcome to KweenBirb's 3rd installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Fallout.sol, the 3rd challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Ethernaut instructs us simply to 'claim ownership of the contract below to complete this level.' After completing the first two simple challenges, this one finally introduces us to the Solidity Remix IDE, where we'll be spending a lot of time over the next several challenges before moving into a local development environment like Forge or Hardhat.

And yet, the source code for the contract is entirely empty, save for a cute ascii art rendition of a cat inquisitively meowing at you. All in comments, of course.

So, since there's no receive() or fallback() function to accept ether, how are you supposed to raise the balance of this contract above 0?

Well, believe it or not there's a specific opcode, part of whose entire purpose is to achieve this effect! That opcode is called selfdestruct() and it is used to completely clear a contract address of bytecode and forward that contract.balance to a new address of the invoker's choosing.

The selfdestruct() opcode, modified in EIP6 from the name suicide() out of respect for those suffering from mental health issues, can produce all sorts of unexpected behaviors when used in code that was not written specifically with those effects in mind. This will become more evident in later Ethernaut levels.

For now, all we have to do is invoke the opcode and raise the balance of our kute lil kitty kontrakt!

To do so, we simply hop over to Remix (or Foundry, if you're a Solidity fanboi like me) and write a simple smart contract with this function:

```
function pwn() public payable {
        selfdestruct(payable(target));
    }
```
    
Once we've deployed, funded, and called pwn() on-chain, bam! Ether has been forwarded from our now-defunct malicious contract to the kute kitty kontrakt which, as it were, has no way to move or withdraw those Eths. Those tokens are now burned forever. Sajj.

Oh well, good job! h00t h00t!

Fun fact: Vitalik Buterin has been loudly clamoring for the selfdestruct() opcode to be eliminated from Solidity for a while now! It's possible that this challenge is eventually rendered irrelevant, but for now it's a fun little trick.
