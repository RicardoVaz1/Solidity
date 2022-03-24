async function main() {
  const MainContract = await ethers.getContractFactory("MainContract")
  console.log("Deploying proxy, maincontract implementation, and proxy admin...") 
    // Only gonna deploy all 3 in the fisrt time we did that
        // Contract Address --> maincontract implementation
        // ProxyAdmin --> proxy admin (define how to work w/ ours proxy contract)
        // TransparentUpgradeableProxy --> ?
        
    // The second time we call deployProxy it'll only deploy the implementation
  
  const maincontract = await upgrades.deployProxy(MainContract, [0], { initializer: 'initial' })
  console.log("MainContractProxy deployed to: ", maincontract.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })