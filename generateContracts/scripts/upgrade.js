async function main() {
    const MainContractV2 = await ethers.getContractFactory("MainContractV2")
    let maincontract = await upgrades.upgradeProxy("Address_TransparentUpgradeableProxy", MainContractV2) // paste the Address_TransparentUpgradeableProxy inside ""
    console.log("Your upgraded proxy is done, with the address: ", maincontract.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })