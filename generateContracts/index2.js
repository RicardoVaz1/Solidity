require("dotenv").config();
var Web3 = require('web3')

var web3 = new Web3(new Web3.providers.HttpProvider(process.env.RINKEBY_RPC_URL));
web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY);
// web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY2);
// web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY3);
// web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY4);

const contractAddress = "0x8E3808FB8D9ED83DE2DEAf3b6B786B82876F8910";
const contractABI = require('./artifacts/contracts/mainContract.sol/MainContract.json');


const ownerAddress = process.env.OWNER_ADDRESS;
const merchantAddress = process.env.MERCHANT_ADDRESS;
const merchantName = process.env.MERCHANT_NAME;

(async () => {
    const contractInstance = new web3.eth.Contract(contractABI.abi, contractAddress);
    contractInstance.setProvider(web3.currentProvider)

    await contractInstance.methods.addMerchantContract(merchantAddress, merchantName).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant ", merchantName, " w/ address ", merchantAddress, " was added!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.getMerchantAddress(0).call({ "from": ownerAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant address is: ", res);
    });

    await contractInstance.methods.changeEscrowTime(0, 12345).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("EscrowTime changed!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.pauseMerchantContract(0).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant paused!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.unpauseMerchantContract(0).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant unpaused!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.removeMerchantContract(0).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant removed!");
        console.log("Transaction Hash: " + res);
    });
})()