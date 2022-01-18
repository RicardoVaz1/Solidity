require("@nomiclabs/hardhat-waffle");
// import { ACCOUNT_PRIVATE_KEY } from "./keys.js";
const { ACCOUNT_PRIVATE_KEY } = require("./keys.js");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  paths: {
    artifacts: "./src/artifacts",
  },

  //It's here that we can define the Network that we want to use
  networks: {
    hardhat: {
      chainId: 1337,
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/b660d6d6827d44a9a3571166604186cb",
      // accounts: [`0x${process.env.ACCOUNT_PRIVATE_KEY}`], //The private key came from Metamask
      accounts: [`0x${ACCOUNT_PRIVATE_KEY.key}`], //The private key came from Metamask
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/b660d6d6827d44a9a3571166604186cb",
      accounts: [`0x${ACCOUNT_PRIVATE_KEY.key}`], //The private key came from Metamask
    },
  },
};

// console.log("KEY: ", ACCOUNT_PRIVATE_KEY.key);
