# Ethernaut Walkthrough: Elevator
## Welcome to KweenBirb's 12th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Elevator.sol, the 12th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt and .sol files in this directory. Let's begin!

Ethernaut instructs us to defeat this level by simply 'using the Elevator to reach the top floor of the Building.' Easier said than done!

The provided source code shows us we'll be working with two contracts, one called Building that has been abstracted to an interface and another called Elevator that is only a few lines of code long.

At first glance, we note that Building must be the contract that determines if we have reached the top floor or not, based on its function named isLastFloor().

The Elevator contract appears to provide a function that servs as a way for us to access different floors in the building, but with a nasty little if clause:

```
if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
```

What gives!? KweenBirb knows she's a birb and all so she can just fly to whatever floor she wants but those lines are just nonsensical! In pseudocode:

if:
    the Building interface contract's isLastFloor() function returns a false value, 
        Elevator's boolean storage variable (called top) is assigned the return value from the Building interface contract's isLastFloor() function. 
        
Yeah, you heard me- boolean storage variable top will be set to the exact same function return value that we literally just got a false value from.

## KweenBirb likes herring, red or not.
I know what you're thinking: "well, what if isLastFloor() returns true?" Nice try, but in that case goTo() just does nothing. Either way, it's initialized by default to false (as booleans always are in Solidity).

But hang on a second, the Building contract is not a fully implemented contract here, only an interface. Ethernaut is clearly implying we should be implementing the Building contract in a way that hacks this if statement.

Come to think of it, the building instance is called twice here: first to check the if statement and then a second time to assign our boolean storage variable top a value... How about we just Heisenberg this shit!?

## Heisenberg this shit

We're looking to write a malicious implementation of Building that alters the speed or position (ie return value) of isLastFloor() when it's measured (ie called). So, let's use a function that flips a switch when the function is called!

```
contract Building {
    bool flip;

    constructor(address $your_ethernaut_address_here) {
        Elevator elevator = Elevator($your_ethernaut_address_here);
        flip = true;
    }

    function isLastFloor(uint _floor) public returns (bool) {
        if (flip) {
            flip = false;
        } else {
            flip = true;
        }
        return flip;
    }
}
```

Now, when the Elevator contract first calls into the Building contract, it'll set our boolean flip variable to false and then return it, triggering the logic inside goTo()'s if block, which then calls back into Building again, this time jumping to the else block and switching flip to true, which will in turn assign Elevator's boolean storage variable top to true. We've hit the top, baby!

## lol jk not yet

Well, not quite. We still need to satisfy Elevator's goTo() function instantiating building at msg.sender as shown here:

```
    Building building = Building(msg.sender);
```

To do so, we just need to finish out with a function that calls Elevator with any _floor uint of your choosing.

```
function imATop() public {
        elevator.goTo(69);
    }
```

Be sure not to forget creating a contract interface for Elevator first!

```
interface Elevator {
    function goTo(uint _floor) external;
}
```

Deploy your attacker contract and call the function we made to hack Elevator.sol and voila! You're on top!

○•○ h00t h00t ○•○