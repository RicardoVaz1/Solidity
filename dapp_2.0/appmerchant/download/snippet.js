// const snippetData = "Hello world";
// export default snippetData;

import { contractABI, contractAddress } from '../lib/constants'
import { ethers } from 'ethers'
require("dotenv").config();

const axios = require('axios');

async function convertToETH(total, currency) {
    try {
        if(currency == "€") currency = "EUR"
        if(currency == "$") currency = "USD"
        
        response = await axios.get('https://pro-api.coinmarketcap.com/v2/tools/price-conversion?amount='+total+'&symbol='+currency+'&convert=ETH',
            { headers: { 'X-CMC_PRO_API_KEY': process.env.API_KEY } });

        var inf = response.data;

        var ETH_price = await inf.data[0].quote.ETH.price;
        var timestamp = await new Date(inf.data[0].quote.ETH.last_updated)
        //var date = timestamp.toISOString().split('T')[0].split("-").reverse().join("-")
        //var time = [timestamp.getHours(), timestamp.getMinutes(), timestamp.getSeconds()].join(":")
        var date1 = await timestamp.toLocaleString('pt-PT');

        console.log("On " + date1 + " the amount " + total + " " + currency + " is " + ETH_price+" ETH")

        return ETH_price;

    } catch(error) {
        console.log(error);
    }
}


async function saveTransaction(transactionHash, amount, BuyerAddress, MerchantAddress) {
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
}

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


        const provider = new ethers.providers.Web3Provider(ethereum)
        const signer = provider.getSigner()
        const transactionContract = new ethers.Contract(contractAddress, contractABI, signer)

        const amount = convertToETH(total, currency) // amountEUR/3235  -->  1 ETH = 3235 EUR
        const parsedAmount = ethers.utils.parseEther(amount)

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

        await saveTransaction(transactionHash, amount, BuyerAddress, MerchantAddress)

    } catch (error) {
        console.error(error)
        throw new Error('No ethereum object.')
    }
}

export default snippetData