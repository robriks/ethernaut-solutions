view functionality blocks a hack similar to the one for elevator:
solidity w/ boolean switch to return different value on second call; this is blocked by view restrictions

tried to write a fallback that would execute even with incoming price() call. had to use assembly in order to provide a return value,

// fallback() external {
    //     if (!a) {
    //         a = true;
    //         assembly {
    //             let fake := 0x07
    //             mstore(0x40, fake)
    //             return(0x40, 0x20)
    //         }
    //     }

    //     if (a) {
    //         a = false;
    //         assembly {
    //             let price := 0x00
    //             mstore(0x40, price)
    //             return(0x40, 0x20)
    //         }
    //     }
    // }

tried using a library as view functions are no longer blocked by STATICCALL but a simple DELEGATECALL (with diamond store pattern it should work in theory, but still got view restriction issues)
>see LibraryAttempt.sol for more information

struct Juke {
    uint heisenberg;
}

function diamondStore() internal pure returns (Juke storage j) {
    bytes32 position = keccak256("diamond.standard.diamond.storage");
    assembly { j.slot := position }
}

function flip() internal returns (uint) {
    Juke storage j = diamondStore();
    if (j.heisenberg = 0) {
        uint res = j.heisenberg;
        j.heisenberg = 102;
    } else {
        uint res = j.heisenberg;
        j.heisenberg = 0;
    }
    return res;
}

Learned tangential tidbit:
Using Remix to deploy a contract with a library reference in it is nifty because Remix automatically recognizes and formats two transactions to initialize the library contract before deploying your reliant contract!

finally came around to solution:
no need to be concerned with view restrictions if the target contract flips a boolean value between function calls for you! Turns out the first solution I tried was the closest to a working hack; just needed to utilize the already implemented isSold boolean variable rather than find a way to circumvent view restrictions and write to storage.

Kweenbirb spent many fruitless hours and yet she learned lots of assembly and library details while diving down deadend rabbitholes though. Owls like kweenbirb sure do love dead rabbits after all.
