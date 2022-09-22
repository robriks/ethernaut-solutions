# Ethernaut Walkthrough: Preservation
## Welcome to KweenBirb's 17th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Preservation.sol, the 17th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file and .sol file in this directory. Let's begin!

In this challenge, Ethernaut describes a scheme of timezone libraries that manage the storage variables of a central contract via delegatecall. We're instructed simply 'to claim ownership of the instance you are given.'

As we know from earlier challenges, one must be very careful when making use of delegatecall and libraries. Storage variables between library contracts, proxies, implementations, and calling contracts must always EXACTLY match! This is due to the fact that code executed via delegatecall will always preserve contract context down to each single byte in terms of variable location, data, and order. Since the name of this challenge is Preservation.sol, that's surely our venue for exploitation here.

On first glance, a couple of interesting design choices stand out. The first is the bytes4 storage variable in the Preservation contract:

```
bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));
```

This is not in itself a security issue but it's not particularly secure if there is a way to change the target address on which the 4 byte function signature is invoked. We'll keep that in mind for later on, in case it is possible to swap out the intended target from underneath a function call and insert our own hacker contract instead.

The second, more problematic design flaw that should stand out is that library contract code only contains one storage variable, whereas the Ethernaut instance, Preservation.sol, contains five storage variables. This means both libraries, the locations for which are presumably stored in public storage addresses timeZone1Library and timeZone2Library, are vulnerable to delegatecall storage manipulation.

## Manipulating storage using a library delegatecall

The Preservation.sol instance provides two handy functions that each serve the same purpose: to perform a low-level delegatecall on public storage addresses timeZone1Library and timeZone2Library, providing the abi encoded 4 byte function signature for "setTime(uint256)" as well as a _timeStamp parameter.

Unfortunately for Ethernaut, their time zone LibraryContract executes the setTime() function on its single storage uint storedTime variable, which in the preserved context of Preservation actually leads to the first public storage address timeZone1Library to be overwritten. Not very well written code; essentially unusable for its intended purpose!

Okay, so here's how the heist is gonna go down:
To make malicious use of this bug, we'll need to typecast the address of a malicious contract into a uint that will be provided to the instance's setFirstTime() function, delegatecalled over to the timeZone1Library library contract, which will in turn use the bug we identified to manipulate the instance's timeZone1Library public storage address to reflect the 'uint' address of our malicious contract that we provided to setFirstTime() in the first place. 

You with me? ... Yeah you should probably reread that last paragraph. 😉😉😉

Great, once we've changed timeZone1Library to reflect our malicious contract, we have to utilize the constant storage bytes4 function signature we noted earlier to make sure that our inserted contract will accept a "setTime(uint256)" function call and use some custom malicious logic to update the Preservation instance's owner variable. More on that later. Once we've accomplished all that, we will have completed the level. Whew.

You son of a gun, I'm in!

## Priming the attacker contract for our heist

Now that we have a gameplan, let's build the exploiter contract. Let's start by giving our hacker contract the storage layout that Ethernaut should have been using all along:

```
contract Prober {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 
    uint storedTime;
    /*
    */
}
```

That will make manipulating the public storage address owner variable simple later on when we reach that part of the heist.

Our next step, as previously outlined, is to typecast the address of the hacker contract into the uint256 that Ethernaut's Preservation instance will expect when its "setFirstTime(uint256)" function is called:

```uint256(uint160(address(this)))```

This will be the parameter we feed to Preservation's setFirstTime() function to inject (via context-preserving delegatecall storage variable manipulation) the address of our malicious contract into Preservation's timeZone1Library variable:

```preservation.setFirstTime(uint256(uint160(address(this))));```

That's the first half of our exploit; the second half will require us to cause the Preservation instance to perform a second delegatecall, this time to our malicious contract with a malicious implementation of "setTime(uint256)"

Speaking of, we haven't yet implemented that!

### Implementing the attacker contract's setTime() function

Since we know we'll be making the Preservation instance call into our attacker contract with the abi encoded signature of "setTime(uint256)" all we have to do is mimic that function, this time maliciously.

```
function setTime(uint _time) public {
    uint time = _time;
    timeZone1Library = address(this);
    timeZone2Library = address(this);
    owner = address(uint160(time));
    storedTime = time;
}
```

This way, the instance's delegatecall to our attacker 'library' won't raise any alarms or revert. It'll simply set all the storage variables, which we aligned to Preservation.sol properly this time, to values that we prefer. Most importantly, Preservation's public storage address owner will be set to whatever uint Preservation passes us- yet another variable we can control earlier along in the execution flow!

Now that we've implemented our version of setTime(), we can finish the second half of the exploit function we designed previously:

```
function attack() public {
    // the first half of the exploit
    preservation.setFirstTime(uint256(uint160(address(this))));
    // the newly finished second half
    preservation.setFirstTime(uint256(uint160(msg.sender)));
}
```

Passing in the uint typecasted msg.sender will provide Preservation with the address that will get passed along the delegatecall into our malicious setTime() function and update the instance's owner variable to the typecasted msg.sender address: us!

What a complicated flow of execution! But we're on the heist's final stretch: just deploy our evil contract, point it at Ethernaut's Preservation instance, and call attack() to completely pwn the instance's storage variables and become owner. h00t h00t

Slick, no?
○•○ h00t h00t ○•○