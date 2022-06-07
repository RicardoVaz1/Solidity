const main = async () => {
  const transactionFactory = await hre.ethers.getContractFactory('MerchantContract')
  const transactionContract = await transactionFactory.deploy(/*process.env.OWNER_ADDRESS,*/ process.env.MERCHANT_ADDRESS, process.env.MERCHANT_NAME)

  await transactionContract.deployed()

  console.log('MerchantContract deployed to:', transactionContract.address)
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