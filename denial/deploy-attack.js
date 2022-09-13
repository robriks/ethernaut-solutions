const hre = require("hardhat");

async function main() {
  const Attack = await hre.ethers.getContractFactory("Attack");
  const attack = await Attack.deploy();

  await attack.deployed();

  console.log("Attack deployed to:", attack.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});