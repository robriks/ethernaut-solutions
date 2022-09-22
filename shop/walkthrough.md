# Ethernaut Walkthrough: Shop
## Welcome to KweenBirb's 22nd installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Shop.sol, the 22nd challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in this directory. Let's begin!

In this challenge, Ethernaut prompts us with only one sentence: 'Can you get the item from the shop for less than the price asked?' 

The instance contract itself is reminiscent of the earlier Elevator challenge, down to the external implementation given by the user as well as its simple structure! Maybe that's a hint that the public storage boolean isSold variable is important in a way, just like the boolean we used to solve Elevator...

Looking closer, we can see two external calls to the contract that we have yet to implement and a switch that flips the isSold boolean between them. Definitely getting Elevator vibes. 

This time, however, the interface given for our malicious Buyer contract only exposes a single view function. How are we supposed to break something with a view function!?

**KweenBirb actually delved deep into using fallbacks with returndata implemented in assembly, broken view functionality of libraries, and even Nick Mudge's favorite: EIP2535 diamond proxies before realizing there is a simpler solution. More on EIP2535 diamonds here:

https://eip2535diamonds.substack.com/

## Anyway, so turns out view functions only block internal state alterations. Duh!

A view function cannot alter its contract state internally. Of that, we're sure. But that doesn't stop it from reading external changes and returning data based on those external conditions!

Where am I going with this? Like in Elevator, we have a boolean switch that flips between Shop's external calls- but this time it's within the Shop contract and not within our own malicious contract. So all we have to do is read the Shop state and observe the switch being flipped to return differing data.

So let's do exactly that when we implement the price() function:

```
function price() public view returns (uint heisenberg) {
        bool isSold = shop.isSold();
        if (!isSold) { return 150; }
        if (isSold) { return 0; }
}
```

This way, the first call to our Buyer contract inside this if statement:

```if (_buyer.price() >= price && !isSold)```

will return 150, satisfying the price and !isSold check. But the second call to our Buyer contract, which actually sets the price uint in storage, will happen after isSold is flipped to true!

```
isSold = true;
price = _buyer.price();
```

This means the second call will actually check Shop's boolean and then return 0 instead of 150. Brilliant!

## Time to 'buy' for free!

Now that we've implemented a clever price() exploit, we just need to give our Buyer contract (more of a Thief, really) a way to call Shop's buy() function:

```
function steal() public {
        shop.buy();
}
```

Freebies for all!
○•○ h00t h00t ○•○
