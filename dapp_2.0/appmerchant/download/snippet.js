// const snippetData = "Hello world";
// export default snippetData;

import { MerchantContractABI, MerchantContractAddress } from '../lib/constants'
import { ethers } from 'ethers'
require("dotenv").config();
var Web3 = require('web3');

const axios = require('axios');

async function convertToETH(total, currency) {
    let response = null;
    try {
        if(currency == "€") currency = "EUR"
        if(currency == "$") currency = "USD"

        response = await axios.get('https://pro-api.coinmarketcap.com/v2/tools/price-conversion?amount='+total+'&symbol='+currency+'&convert=ETH',
        { headers: { 'X-CMC_PRO_API_KEY': process.env.PRO_API_KEY } });

    } catch(error) {
        console.log(error);
    }
    if (response) {      
        var inf = response.data;
        // console.log(inf)

        var ETH_price = inf.data[0].quote.ETH.price;
        var timestamp = new Date(inf.data[0].quote.ETH.last_updated)
        var date = timestamp.toLocaleString('pt-PT');
        console.log("On " + date + " -> " + total + " " + currency + " = " + ETH_price+" ETH")

        return ETH_price;
    }
}


/*async function saveTransaction(transactionHash, amount, BuyerAddress, MerchantAddress) {
    let response = null;
    let token = null;

    try {
        token = await axios.get('http://localhost:3000/gettoken?merchantaddress='+MerchantAddress);
        console.log("Token: ", token);
    } catch(error) {
        token = null;
        alert("Error! Try again, please!")
        console.log("Error getting token! " + error);
        return
    }

    if (token) {
        try {
            response = await axios.get('http://localhost:3000/savetransaction/'+token+'?transactionhash='+transactionHash.hash+'&amount='+amount+'&buyeraddress='+BuyerAddress+'&merchantaddress='+MerchantAddress);
        } catch(error) {
            response = null;
            alert("Error! Try again, please!")
            console.log(error);
        }
        if (response) {
            alert("Done Successfully!")
        }
    }
}*/

const snippetData = async function payWithCrypto(total, currency) {
    // total: is the amount in euro or dollar, currency: is the symbol EUR or USD
    // In the Checkout > Crypto RadioButton should add this:  onClick={() => payWithCrypto(total, currency)}
    // And add this function in your server

    let metamask

    if (typeof window !== 'undefined') {
        metamask = window.ethereum
    }

    try {
        if (!metamask) return alert('Please install metamask ')

        const accounts = await metamask.request({ method: 'eth_requestAccounts' })
        const BuyerAddress = accounts[0]

        const amount = convertToETH(total, currency)
        const parsedAmount = ethers.utils.parseEther(amount)

        /*
        const provider = new ethers.providers.Web3Provider(ethereum)
        const signer = provider.getSigner()
        const transactionContract = new ethers.Contract(MerchantContractAddress, MerchantContractABI, signer)
        
        await metamask.request({
            method: 'eth_sendTransaction',
            params: [
                {
                    from: BuyerAddress,
                    to: MerchantAddress,
                    gas: '0x7EF40', // 520000 Gwei
                    value: parsedAmount._hex,
                },
            ],
        })

        const transactionHash = await transactionContract.deposit(
            BuyerAddress,
            MerchantAddress,
            parsedAmount,
            `Transferring ${parsedAmount} ETH from ${BuyerAddress} to ${MerchantAddress}`
        )

        await transactionHash.wait()
        await saveTransaction(transactionHash, amount, BuyerAddress, MerchantAddress)*/


        /* ========== MERCHANT ========== */
        var web3_Mechant = new Web3(MerchantAddress);
        let MerchantContract = new web3_Mechant.eth.Contract(MerchantContractABI, MerchantContractAddress);
        // let amount = 1;
        // amount = web3.utils.toWei(amount.toString(), 'ether');
        let MerchantResponse = await MerchantContract.methods
            .createPurchase(idPurchase, parsedAmount)
            .send({
                from: MerchantAddress,
                to: MerchantContractAddress,
                // value: parsedAmount._hex,
                gasPrice: '20000000000'
            });
        console.log("Merchant response: ", MerchantResponse);


        /* ========== BUYER ========== */
        var web3_Buyer = new Web3(web3.currentProvider);
        let _MerchantContract = new web3_Buyer.eth.Contract(MerchantContractABI, MerchantContractAddress);
        // let amount = 1;
        // amount = web3.utils.toWei(amount.toString(), 'ether');
        let BuyerResponse = await _MerchantContract.methods
            .buy(idPurchase, parsedAmount)
            .send({
                from: window.web3.currentProvider.selectedAddress,
                to: MerchantContractAddress,
                value: parsedAmount._hex,
                gasPrice: '20000000000'
            });
        console.log("Buyer response: ", BuyerResponse);

    } catch (error) {
        console.error(error)
        throw new Error('No ethereum object.')
    }
}

export default snippetData