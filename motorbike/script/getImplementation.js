require('dotenv').config()
const { getImplementationAddress } = require('@openzeppelin/upgrades-core')
const { ethers } = require('ethers')

const main = async () => {

    // load onchain and api variables using dotenv library
    const proxyAddress = process.env.proxyAddress
    const projectId = process.env.projectId

    const provider = new ethers.providers.InfuraProvider("rinkeby", projectId)

    const targetImpl = await getImplementationAddress(provider, proxyAddress)
    console.log('Logic implementation address located at: ' + targetImpl)
}

main()