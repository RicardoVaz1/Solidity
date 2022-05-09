const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

let MainContract
let maincontract

let OwnerAddress = process.env.OWNER_ADDRESS
let NewOwner = process.env.NEW_OWNER
let MerchantAddress = process.env.MERCHANT_ADDRESS
let MerchantName = process.env.MERCHANT_NAME

describe("MainContract:", () => {
  // console.log("Owner: ", OwnerAddress)
  // console.log("NewOwner: ", NewOwner)
  // console.log("Merchant: ", MerchantAddress)
  // console.log("Merchant Name: ", MerchantName)
  
  beforeEach(async () => {
    MainContract = await ethers.getContractFactory("MainContract")
    maincontract = await upgrades.deployProxy(MainContract, [OwnerAddress], { initializer: 'initialize' })
  })
  

  /* ========== SYSTEM ========== */
  it("Testing function getOwnerAddress", async () => {
    // expect(await maincontract.getOwnerAddress())
    // expect((await maincontract.getOwnerAddress()).toString()).to.equal(OwnerAddress);

    try {
      let result = await maincontract.getOwnerAddress().call({from: OwnerAddress})
      assert.equal(result.toString(), OwnerAddress)
      console.log("That's the Owner address!")
    } catch (error) {
      console.log("That's not the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function pauseSystem", async () => {
    try {
      await maincontract.pauseSystem().call({from: OwnerAddress})
      console.log("System is Paused!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function unpauseSystem", async () => {
    try {
      await maincontract.unpauseSystem().call({from: OwnerAddress})
      console.log("System is Unpaused!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function transferOwnership", async () => {
    try {
      await maincontract.transferOwnership(NewOwner).call({from: OwnerAddress})

      let result = await maincontract.getOwnerAddress().call({from: NewOwner})
      assert.equal(result.toString(), NewOwner)      
      console.log("Owner changed successfully!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function renounceOwnership", async () => {
    try {
      await maincontract.renounceOwnership().call({from: OwnerAddress})

      let result = await maincontract.getOwnerAddress().call({from: OwnerAddress})
      assert.equal(result.toString(), OwnerAddress)
      console.log("Owner changed successfully!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  /* ========== MERCHANTs ========== */
  it("Testing function addMerchant", async () => {
    try {
      await maincontract.addMerchant(MerchantAddress, MerchantName).call({from: OwnerAddress})
      console.log("Merchant added successfully!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function pauseMerchant", async () => {
    try {
      await maincontract.pauseMerchant(MerchantAddress).call({from: OwnerAddress})
      console.log("Merchant paused!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function unpauseMerchant", async () => {
    try {
      await maincontract.unpauseMerchant(MerchantAddress).call({from: OwnerAddress})
      console.log("Merchant unpaused!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);


  it("Testing function removeMerchant", async () => {
    try {
      await maincontract.removeMerchant(MerchantAddress).call({from: OwnerAddress})
      console.log("Merchant removed!")
    } catch (error) {
      console.log("That isn't the Owner address! - ", error)
    }
  }).timeout(10000);
});