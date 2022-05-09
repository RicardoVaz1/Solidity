const axios = require('axios')
require("dotenv").config();

async function verifyFinality(txhash, apikey) {
  // Get the receipt of a transaction by transaction hash
  let response = null;
  try {
    response = await axios.get('https://api-rinkeby.etherscan.io/api?module=proxy&action=eth_getTransactionReceipt&txhash='+txhash+'&apikey='+apikey);
  } catch(error) {
    console.log(error);
  }
  if (response) {
    var inf = response.data;
    // console.log("Inf: ", inf)

    var ID_my_block = inf.result.blockNumber;
    var my_block = parseInt(ID_my_block, 16)
    console.log("ID My Block -> hex: ", ID_my_block, ", int: ", my_block)


    // Get the number of most recent block
    let response2 = null;
    try {
      response2 = await axios.get('https://api-rinkeby.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey='+apikey)
    }
    catch (error) {
      console.log(error);
    }
    if(response2) {
      var info = response2.data;
      // console.log("Inf: ", info)

      var ID_last_block = info.result;
      var last_block = parseInt(ID_last_block, 16)
      console.log("ID Last Block -> hex: ", ID_last_block, ", int: ", last_block)


      // Finality in Ethereum -> wait 6 blocks
      if(my_block+6 < last_block) return true;
      else return false;
    }
  }
}


var result = verifyFinality(process.env.TRANSACTION_HASH, process.env.API_KEY)

Promise.resolve(result)
  .then((value) => console.log("Finality Result: ", value)) // true = transaction finished; false = transaction not finished
  .catch((error) => console.log("Error: ", error))