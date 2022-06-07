const main = async () => {
  const transactionFactory = await hre.ethers.getContractFactory('MainContract')
  // const transactionContract = await transactionFactory.deploy()
  const transactionContract = await transactionFactory.deploy(process.env.OWNER_ADDRESS)

  await transactionContract.deployed()

  console.log('MainContract deployed to:', transactionContract.address)
}
  
;(async () => {
  try {
    await main()
    process.exit(0)
  } catch (error) {
    console.error(error)
    process.exit(1)
  }
})()