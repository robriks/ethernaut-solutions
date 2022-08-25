object "contract" {
    code {
        // deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            mstore(0x40, 0x2a)
            return(0x40, 0x20)
        }
    }
}