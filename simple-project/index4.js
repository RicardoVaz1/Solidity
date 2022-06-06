require("dotenv").config();
var Web3 = require('web3')

var web3 = new Web3(new Web3.providers.HttpProvider(process.env.RINKEBY_RPC_URL));
web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY);

const contractAddress = "0xF64AB73573b193aA1969395508d97e601DA3DC96";
const contractABI = require('./artifacts/contracts/sendMoney.sol/StructMapping.json');

const fromAddress = process.env.FROM_ADDRESS;
const toAddress  = process.env.TO_ADDRESS;
const amount = 1;


(async () => {
    const contractInstance = new web3.eth.Contract(contractABI.abi, contractAddress);
    contractInstance.setProvider(web3.currentProvider)

    await contractInstance.methods.sendMoney().send({
        "from": fromAddress,
        "value": amount,
        // "gasLimit": 21064
        "gas": 1500000,
        "gasPrice": '30000000000'
    }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("Address " + fromAddress, " sent ", amount, " to ", contractAddress);
        console.log("Transaction Hash: " + res);
    });

    await contractInstance.methods.getBalance().call({ "from": fromAddress }, (err, res) => {  
        if(err) {
            console.log(err);
            return
        }
        console.log("\n\nBalance of address ", fromAddress, " is: ", res);
    });

    await contractInstance.methods.withdrawAllMoney(toAddress).send({
        "from": fromAddress,
        "gas": 1500000,
        "gasPrice": '30000000000'
    }, (err, res) => {
        if(err) {
            console.log(err);
            return
        }
        console.log("\n\nMoney sent to: " + toAddress);
        console.log("Transaction Hash: " + res);
    });
})()