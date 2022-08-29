welcome snippet

unlike previous ethernaut level dex, swap function no longer requires set token1 and token2 addresses! This gives us an additional attack vector to the previous economic liquidity attack we executed on dex1: a spoofed contract code injection opportunity!

let's create a custom malicious token to provide unexpected erc20 values to dex contract and drain both sides of the liquidity pool

suggestions for improvement: rather than invoking IERC20() calls on the provided parameters: address from, address to; simply anchor those calls to the storage variables: address token1, address token2.