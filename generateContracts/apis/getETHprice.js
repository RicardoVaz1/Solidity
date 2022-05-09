const axios = require('axios')
require("dotenv").config();

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


var ETH = convertToETH(10, "$")

Promise.resolve(ETH)
  .then((value) => console.log("ETH price: ", value))
  .catch((error) => console.log("Error: ", error))