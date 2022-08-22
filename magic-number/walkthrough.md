--introooo

-- evm opcodes needed, discuss stack machine, runtime bytecode vs initcode
    PUSH 20
    PUSH 40
    PUSH 2a
    DUP2
    MSTORE
    RETURN

runtime bytecode: 60206040602a8152f3
initcode:

-- second solution using Yul: discuss yul as assembly language with very little abstraction over evm opcodes

discuss structure of yul contracts (in terms of alrdy discussed initcode, runtime)

note that solution.yul code deploys a contract with different bytecode than what we came up with in the first solution due to lack of optimization
