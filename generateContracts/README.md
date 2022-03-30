# generateContracts:

- [Contracts](/generateContracts/contracts)
    - [MainContract](/mainContract.sol)
    - [MerchantContract](/merchantContract.sol)
    - [Libraries](/Libraries.sol)

- [Scripts](/scripts)
    - To deploy MainContract: **npx hardhat run scripts/deploy.js**
    - Compile MainContract: **npx hardhat console --network rinkeby**
        > const MainContract = await ethers.getContractFactory("MainContract")
        > const maincontract = await MainContract.attach("Address_TransparentUpgradeableProxy")

    - To deploy MainContractV2: **npx hardhat run scripts/upgrade.js**
    - Compile MainContractV2: **npx hardhat console**
        > const MainContractV2 = await ethers.getContractFactory("MainContractV2")
        > const maincontractV2 = await MainContractV2.attach("Address_TransparentUpgradeableProxy")

- [Test](/test)
    - To test use: **npx hardhat test**
