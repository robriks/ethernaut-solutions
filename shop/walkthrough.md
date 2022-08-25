tried solidity w/ boolean switch to return different value on second call; blocked by view restrictions

tried assembly fallback; blocked by STATICCALL opcode

try using a library as view functions are no longer blocked by STATICCALL but a simple DELEGATECALL

