const { expect } = require("chai");
const { ethers } = require("hardhat");
require("dotenv").config();

let MerchantContract
let merchantContract

let OwnerAddress = process.env.OWNER_ADDRESS
let MerchantAddress = process.env.MERCHANT_ADDRESS
let MerchantName = process.env.MERCHANT_NAME
let NewMerchant = process.env.NEW_MERCHANT
let BuyerAddress = process.env.BUYER_ADDRESS

describe("MerchantContract:", () => {
  // console.log("Owner: ", OwnerAddress)
  // console.log("Merchant: ", MerchantAddress)
  // console.log("Merchant Name: ", MerchantName)
  // console.log("New Merchant: ", NewMerchant)
  // console.log("Buyer: ", BuyerAddress)

  beforeEach(async () => {
    MerchantContract = await ethers.getContractFactory("MerchantContract")
    merchantContract = await MerchantContract.deploy(OwnerAddress, MerchantAddress, MerchantName)
  })


  /* ========== SYSTEM ========== */
  it("Testing function getMerchantAddress", async () => {
    try {
      let result = await merchantContract.getMerchantAddress().call({from: OwnerAddress})
      // let result = await merchantContract.getMerchantAddress2(1).call({from: OwnerAddress})
      assert.equal(result.toString(), MerchantAddress)
      console.log("That's the Merchant address!")
    } catch (error) {
      console.log("That's not the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function changeEscrowTime", async () => {
    let NewEscrowTime = 604800 // 7 days = 604800 seconds
    try {
      await merchantContract.changeEscrowTime(NewEscrowTime).call({from: OwnerAddress})
      console.log("Escrow Time Changed!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  /* ========== MERCHANTs ========== */
  it("Testing function changeMerchantAddress", async () => {
    try {
      await merchantContract.changeMerchantAddress(NewMerchant).call({from: MerchantAddress})

      let result = await merchantContract.getMerchantAddress().call({from: OwnerAddress})
      assert.equal(result.toString(), NewMerchant)
      console.log("Merchant changed successfully!")
    } catch (error) {
      console.log("That isn't the Merchant address! - ", error)
    }
  }).timeout(10000);


  /* ========== PURCHASE FLOW ========== */
  it("Testing function buy", async () => {
    try {
      await merchantContract.buy(BuyerAddress, 2).call({from: BuyerAddress})      
      console.log("Done successfully!")
    } catch (error) {
      console.log("Error during the process! - ", error)
    }
  }).timeout(10000);


  it("Testing function complete", async () => {
    try {
      await merchantContract.complete(1, 1).call({from: OwnerAddress})      
      console.log("Done successfully!")
    } catch (error) {
      console.log("Error during the process! - ", error)
    }
  }).timeout(10000);


  it("Testing function sendToMerchant", async () => {
    try {
      await merchantContract.sendToMerchant(1).call({from: OwnerAddress})      
      console.log("Sent to Merchant successfully!")
    } catch (error) {
      console.log("Error during the process! - ", error)
    }
  }).timeout(10000);


  it("Testing function refund", async () => {
    try {
      await merchantContract.refund(BuyerAddress, 10).call({from: MerchantAddress})      
      console.log("Refund done successfully!")
    } catch (error) {
      console.log("Error during the process! - ", error)
    }
  }).timeout(10000);
});