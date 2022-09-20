# Ethernaut Walkthrough: Privacy
## Welcome to KweenBirb's 13th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to Privacy.sol, the 13th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file and .sol file in this directory. Let's begin!

In this challenge, Ethernaut presents us with a contract whose creator 'was careful enough to protect the sensitive areas of its storage.' We're instructed to 'Unlock this contract to beat the level.' Hm.

Looking over the code, we notice two public storage variables: a boolean and a uint256; locked and ID respectively. Those are not interesting, obviously! But following those are four private variables: two uint8s named flattening and denomination; a uint16 named awkwardness; and a bytes32[] array of length 3 called data. The public / private layout of this contract's storage variables implies one or more of those variables will need to be combined with the sole function of the contract: unlock().

Fair enough, let's inspect the unlock() function:

```
function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
}
```

There it is! All we need is to provide as function parameter the third item in the bytes32[] array known as data. There's a twist though, that array item will have to be typecast from bytes32 to a bytes16 type. No big deal for our haxz0r skills!

First we'll extract the item using the bytes array index, but before we do so we should discuss a quick overview of EVM smart contract storage. All solidity types compile down to the bytes32 type as that is the building block of Ethereum data. Each bytes32 unit in storage has what we call a 'storage slot' where your variables, be it strings/uint/bool/bytes and so forth, are stored. These slots generally hold 1 variable each- except in the case of storage packing.

As the name implies, storage packing is when multiple variables are packed into a single storage slot to save on gas costs and state bloat of the network. This is only possible when the size of all packed variables total 32 bytes or less!

Why am I ranting about EVM storage? We have to deconstruct the storage layout of this Ethernaut contract in order to identify which slot to pull our solution _key from. Looking over the instance's storage variables we can do so visually:

```
bool public locked = true;
uint256 public ID = block.timestamp;
uint8 private flattening = 10;
uint8 private denomination = 255;
uint16 private awkwardness = uint16(now);
bytes32[3] private data;
```

Boolean types are the smallest type of all, represented by a single byte (a single bit, really!): 0x00 or 0x01. You'll remember from logic class that 0 == false and 1 == true. Since they're so small, they'll usually be packed automatically with other neighboring variables, especially if the developer who wrote the contract knows what they're doing.

This does not appear to be the case. (Ethernaut is showing us what not to do when ordering storage variables!)

The next variable, a public uint256, occupies an entire 32 bytes of storage! This is because the uint's datasize is 256 bits == 32 bytes. So the bool variable locked gets the first storage slot with tons of wasted space, and the uint256 ID fills up the second storage slot.

Moving on, we see three much smaller variables in a row: flattening; denomination; awkwardness. When combined, these three variables fit into a single slot so they'll be stored in the third storage slot.

That puts the beginning of the bytes32 array data at the fourth slot, implying that our desired item in the array at index 2 is stored in the 6th storage slot. Remember that indexes in Solidity begin at 0, so ```bytes32[2]``` is the third item in the array and the 6th storage slot of the contract will have index 5!

Now that we've identified which slot to read, we can use the web3js library provided by Ethernaut to pull the data from on-chain. We're using off-chain Javascript here as Solidity's private keyword will prevent us from reading the storage slot on-chain.

```await web3.getStorageAt(instance, 5)```

Then all we need to do is take that bytes32 key and typecast it to bytes16 and provide it to the unlock function. Let's get back to Solidity for this:

```
function hack() public {
        bytes16 key16 = bytes16(key);
        privacy.unlock(key16);
}
```

Don't forget that you'll want a brief interface exposing the instance's unlock(bytes16) function:

```
interface Privacy {
    function unlock(bytes16 _key) external;
}
```

and a declaration of the instance as well as the key you pulled using off-chain web3js:

```
Privacy privacy;

constructor(address $your_ethernaut_instance_here) {
    privacy = Privacy($your_ethernaut_instance_here);
}

bytes32 key = 0x5a22993b7dc5779c75164885ee41ef389460244ee855cc9e22e8177b837cd547;
```

Then call your hack() function to unlock Privacy's failed attempt at keeping secrets on-chain. Remember, nothing you put on-chain can be hidden or kept secret because Ethereum, like most blockchains, is 100% transparent at all times. Hopefully one day we'll see protocolized zero-knowledge proof mathematics to provide the privacy we all want and deserve.

But for now, with blockchain in its fledgling years, it's best to have an auditable and provably working system!

h00t h00t