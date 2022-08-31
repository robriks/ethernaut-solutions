goal: change proxy pointer to implementation by becoming admin
function to do so: proposeNewAdmin() -> approveNewAdmin()

function to become owner: init()
-needs maxBalance == 0

function to set maxBalance = 0: setMaxBalance()
-needs address(this).balance == 0 and onlyWhitelisted

function to become whitelisted: addToWhitelist()
-needs owner, a closed loop. how then to break this contract if none of the functions are callable!?

what if we bypass the proxy entirely and call these functions on the logic implementation contract itself? pretty useless, right?

not if the logic implementation is completely untouched- that is to say, if it was deployed without explicitly being initialized, we still have a chance at calling ```init()```

first let's locate the target logic implementation contract. openzeppelin has an awesome library of nifty proxy functions, one of which does exactly this! A short js script will do the trick:

import {getImplementationAddress} from '@openzeppelin/upgrades-core'
const targetImpl = await getImplementationAddress(provider, proxyAddress)

the completed js script is in the ```script``` directory of this repo; it uses the common ethers js framework as well as the ever-useful dotenv library to establish a connection to Rinkeby via Infura.

When we run our nifty getImplementation.js script, a target address is returned to us in the console:
!!!!!!!!!!! IMPORT RESULT.PNG FROM /SCRIPT DIRECTORY

Let's run some quick checks to see if the logic implementation is initialized:

```cast call 0x49B448277D59Ba8d2ca8507f80b2E0633fE72158 --rpc-url $RPC "owner():(address)"```
```cast call 0x49B448277D59Ba8d2ca8507f80b2E0633fE72158 --rpc-url $RPC "maxBalance():(uint256)"```

0 all around!? QUICK CALL INIT(0) BEFORE SOME OTHER H4CK3R DOES! (or, as we are about to do, write it into a malicious contract for the element of surprise)

```cast send --private-key $PRIV_KEY 0x49B448277D59Ba8d2ca8507f80b2E0633fE72158 --rpc-url $RPC "init(uint256)" 0

Howly h00ts, I'M IN!!! 😈😈😈😈😈

PWND! with owner set to KweenBirb's address, we can now add ourselves to the whitelist and use the delegatecall inside the multicall function to manipulate storage variables! Teehee, we're gonna be both pwner and admin!

But wait, hol up 1 sec yo. We just pwned the logic implementation contract, which isn't the Ethernaut instance we were targeting in the first place. Calling these functions on the logic implementation directly doesn't benefit us at all because they don't affect the proxy contract... Unless...


?????????

Looking back at the proxy contract, the only check for the ```init()``` function to become owner is that maxBalance == 0. What if we made the logic implementation selfdestruct()?!

Hmm, nope that won't change the maxBalance storage variable in the proxy contract- init() will still revert via require(). But 