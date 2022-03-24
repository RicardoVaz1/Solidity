const { expect } = require("chai");

let MainContract
let maincontract

// var OWNER_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// var SYSTEM_STATE = false
// var VERSION = 1
// var COUNTER = 0

describe("mainContract (proxy)", function () {
  beforeEach(async function () {
    MainContract = await ethers.getContractFactory("MainContract")
    maincontract = await upgrades.deployProxy(MainContract, [0], { initializer: 'initial' })
  })

  // Test case
  it("getCounter returns the Counter previously initialized", async function () {
    expect((await maincontract.getCounter()).toString()).to.equal('0');
  });
});
