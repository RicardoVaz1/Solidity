require("dotenv").config();
var Web3 = require('web3')

var web3 = new Web3(new Web3.providers.HttpProvider(process.env.RINKEBY_RPC_URL));
web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY2);
web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY3);
// web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY4);

const contractAddress = "0xb7eDd3a5Df776b39223969D2b5e489A57DaDF38e";
const contractABI = require('./artifacts/contracts/merchantContract.sol/MerchantContract.json');


const ownerAddress = process.env.OWNER_ADDRESS;

const merchantAddress = process.env.MERCHANT_ADDRESS;
const merchantName = process.env.MERCHANT_NAME;
const merchantNewAddress = process.env.MERCHANT_NEWADDRESS;

const buyerAddress = process.env.BUYER_ADDRESS;
const amount = 1; // 1 wei


(async () => {
    const contractInstance = new web3.eth.Contract(contractABI.abi, contractAddress);
    contractInstance.setProvider(web3.currentProvider)


    /* ========== SYSTEM ========== */
    await contractInstance.methods.getMerchantAddress().call({ "from": ownerAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("Merchant address is: ", res);
    });

    await contractInstance.methods.changeEscrowTime(12345).send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nEscrowTime changed!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.pauseMerchant().send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMerchant paused!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.unpauseMerchant().send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMerchant unpaused!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.deleteMerchant().send({ "from": ownerAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\n\nMerchant removed!");
        console.log("Transaction Hash: " + res);
    });


    /* ========== MERCHANTs ========== */
    await contractInstance.methods.checkMyAddress().call({ "from": merchantAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("\n\nMy address is: ", res);
    });

    await contractInstance.methods.changeMyAddress(merchantNewAddress).send({ "from": merchantAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMy address is changed!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.checkMyAddress().call({ "from": merchantNewAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMy address is: ", res);
    });

    await contractInstance.methods.checkMyEscrowAmount().call({ "from": merchantAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMy EscrowAmount is: ", res);
    });

    await contractInstance.methods.checkMyBalance().call({ "from": merchantAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("\nMy Balance is: ", res);
    });

    // Purchase Flow
    console.log("\n\nPurchase Flow:");
    await contractInstance.methods.createPurchase(0, amount).send({ "from": merchantAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nPurchase created!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.buy(0).send({ "from": buyerAddress, "value": amount, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nAddress " + buyerAddress, " sent ", amount, " to ", contractAddress);
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.complete(0).send({ "from": merchantAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nPurchase completed!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.sendToMerchant().send({ "from": merchantAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nBalance sent!");
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.refund(0, buyerAddress, amount).send({ "from": merchantAddress, "gas": 1500000, "gasPrice": '30000000000' }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\nRefund complete!");
        console.log("Transaction Hash: " + res);
    });
})()