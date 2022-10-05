// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require('dotenv').config()
const fs = require('fs')

async function main() {
  const Entrant = await hre.ethers.getContractFactory("Entrant");
  // ethernaut instance provided as constructor argument
  const entrant = await Entrant.deploy(process.env.TARGET);

  await entrant.deployed();

  fs.appendFile("./.env", `\nENTRANT='${entrant.address}'`, (err) => {
    if (err) { throw (err) }
    console.log("Entrant deployed to:", entrant.address + " and added to .env file. Proceed with brute-forcing");
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
