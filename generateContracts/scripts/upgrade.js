//const { ethers, upgrades } = require("hardhat")

async function main() {
    const MainContractV2 = await ethers.getContractFactory("MainContractV2")
    let maincontract = await upgrades.upgradeProxy("0xDc8055e19B83a077694FD486Bb6fcbaF60BF1FAd", MainContractV2) // paste the Address_TransparentUpgradeableProxy inside ""
    console.log("Your upgraded proxy is done, with the address: ", maincontract.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })