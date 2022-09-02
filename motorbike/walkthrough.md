welcome snippet

OpenZeppelin asks us to 'selfdestruct its engine and make the motorbike unusable'

Looks like after all that hot air about explodingKittens in the last challenge (Puzzle-Wallet, go check it out if you haven't already as this challenge will make a lot more sense having gone through that one) we will get to explode some kittens after all!

ExplodingKittens is premised on the fact that many upgradeable proxy contracts possess their upgrade logic in the logic implementation contract and that calls are delegatecalled via a fallback function that is indiscriminate towards the selfdestruct() opcode. This can be exasperated if a dapp does not initialize its logic implementation contract (logic implementation contracts' initialize function must be manually invoked, unlike constructors), in which case an attacker may be able to gain permissioned access within a logic contract and maneuver laterally within to wreak other havoc.


In this case, however, the logic implementation is initialized in the proxy contructor:

```
    (bool success,) = _logic.delegatecall(
        abi.encodeWithSignature("initialize()")
    );
    require(success, "Call failed");
```

But thankfully we can see some indiscriminate delegatecall assembly in the _delegate function, which handles every call forwarded to the fallback function:

```
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
```

## Let's get cracking, shall we?

Let's format a selfdestruct() call to pass to the fallback function and see what happens. This should do:

```
function sugarInYourEngine() public {
    address(instance).call(abi.encodeWithSignature('selfdestruct()'));
}
```