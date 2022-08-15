object "42" {
    code {
        // deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            returnUint(42)

            function returnUint(allah) {
                mstore(0, allah)
                return(0, 0x20)
            }
        }
    }
}