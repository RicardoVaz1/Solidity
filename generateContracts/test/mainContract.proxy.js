const { expect } = require("chai");
require("dotenv").config();

let MainContract
let maincontract


describe("mainContract (proxy)", function () {
  beforeEach(async function () {
    MainContract = await ethers.getContractFactory("MainContract")
    maincontract = await upgrades.deployProxy(MainContract, [process.env.OWNER_ADDRESS], { initializer: 'initialize' })
  })
  

  // Test case
  it("getOwnerAddress returns the OwnerAddress previously initialized", async function () {
    // expect(await maincontract.getOwnerAddress())
    expect((await maincontract.getOwnerAddress()).toString()).to.equal(process.env.OWNER_ADDRESS);
  });
});