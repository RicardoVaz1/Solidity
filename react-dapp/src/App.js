import { useState } from "react";
import { ethers } from "ethers";
import "./App.css";
import Greeter from "./artifacts/contracts/Greeter.sol/Greeter.json";
import Token from "./artifacts/contracts/Token.sol/Token.json";
import { Web3Provider } from "@ethersproject/providers";

const greeterAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const tokenAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

//Merchant
var merchantAddress = "0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec";
var merchantBalance = 3;
var precoProduto = 0.5;
// var precoProduto1 = 0.5;
var precoProduto2 = 100;

//Buyer
var buyerAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
var buyerBalance = 2;

function App() {
  async function requestAccount() {
    //connect to the Metamask Wallet of the user
    await window.ethereum.request({ method: "eth_requestAccounts" }); //request the account information from the Metamask Wallet

    //return an array of accounts
  }

  //Exercicio 1
  function buyProduct() {
    /*
    var precoProduto;
    console.log("Numero Produto: " + numProduto);
    precoProduto = "precoProduto" + numProduto;

    switch (numProduto) {
      case "1":
        precoProduto = precoProduto1;
        console.log("Numero Produto: " + precoProduto);
      // break;
      case "2":
        precoProduto = precoProduto2;
        console.log("Numero Produto: " + precoProduto);
      // break;

      default:
        console.log("Produto não existe!");
        break;
    }
    */

    if (buyerBalance >= precoProduto) {
      buyerBalance = buyerBalance.toFixed(2) - precoProduto;
      merchantBalance = merchantBalance + precoProduto;

      document.getElementById("buyerBalance").innerHTML =
        buyerBalance.toFixed(2) + " ETH";
      document.getElementById("merchantBalance").innerHTML =
        merchantBalance.toFixed(2) + " ETH";

      console.log("Preço Produto: ", precoProduto);
      console.log("Merchant Balance: ", merchantBalance);
      console.log("Buyer Balance: ", buyerBalance);
    } else {
      alert("Not enough money!");
      console.log("Not enough money!");
    }
  }

  /* ------- Reembolso ------- */
  const [montanteReembolso, setMontanteReembolso] = useState(0);

  function refundBuyer() {
    if (merchantBalance >= montanteReembolso) {
      merchantBalance = merchantBalance - parseFloat(montanteReembolso);
      buyerBalance = buyerBalance + parseFloat(montanteReembolso);

      document.getElementById("buyerBalance").innerHTML = buyerBalance + " ETH";
      document.getElementById("merchantBalance").innerHTML =
        merchantBalance + " ETH";

      console.log("Preço Produto: ", precoProduto);
      console.log("Merchant Balance: ", merchantBalance);
      console.log("Buyer Balance: ", buyerBalance);
    } else {
      alert("Not enough money!");
      console.log("Not enough money!");
    }

    /*
    if (buyerBalance >= precoProduto) {
      buyerBalance = buyerBalance.toFixed(2) - precoProduto;
      merchantBalance = merchantBalance + precoProduto;

      document.getElementById("buyerBalance").innerHTML =
        buyerBalance.toFixed(2) + " ETH";
      document.getElementById("merchantBalance").innerHTML =
        merchantBalance.toFixed(2) + " ETH";

      console.log("Preço Produto: ", precoProduto);
      console.log("Merchant Balance: ", merchantBalance);
      console.log("Buyer Balance: ", buyerBalance);
    } else {
      alert("Not enough money!");
      console.log("Not enough money!");
    }
    */
  }
  /* ------------------------- */

  //Exercicio 2
  const [greeting, setGreetingValue] = useState("");

  async function fetchGreeting() {
    //It looks if Metamask extension its connected
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(
        greeterAddress,
        Greeter.abi,
        provider
      );

      try {
        const data = await contract.greet();
        console.log("data: ", data);
      } catch (err) {
        console.log("Error: ", err);
      }
    }
  }

  async function setGreeting() {
    if (!greeting) return;
    if (typeof window.ethereum !== "undefined") {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(greeterAddress, Greeter.abi, signer);
      const trasaction = await contract.setGreeting(greeting); //its the greeting variable that's local (it's what user type into the form to update the greeting)

      setGreetingValue("");

      await trasaction.wait(); //wait for the transaction confirmation on blockchain
      fetchGreeting(); //log out the new value
    }
  }

  //Exercicio 3
  async function getBalance() {
    if (typeof window.ethereum !== "undefined") {
      const [account] = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(tokenAddress, Token.abi, provider);
      const balance = await contract.balanceOf(account);
      console.log("Address: ", account, "\nBalance: ", balance.toString(), "R");
    }
  }

  const [userAccount, setUserAccount] = useState("");
  const [amount, setAmount] = useState(0);

  async function sendCoins() {
    if (typeof window.ethereum !== "undefined") {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(tokenAddress, Token.abi, signer);
      const trasaction = await contract.transfer(userAccount, amount);
      await trasaction.wait();
      console.log(`${amount} Coins successfully sent to ${userAccount}`);
      // console.log("Coins successfully sent");
    }
  }

  //Exercicio 4
  async function getBalanceMerchant() {
    if (typeof window.ethereum !== "undefined") {
      // const [account] = await window.ethereum.request({
      //   method: "eth_requestAccounts",
      // });
      const account = merchantAddress;
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(tokenAddress, Token.abi, provider);
      const balance = await contract.balanceOf(account);
      // console.log(account, " Balance: ", balance.toString(), "R");

      // if (account == merchantAddress)
      document.getElementById("merchantBalance2").innerHTML = balance + " R";
    }
  }

  //const [codigoInserido, setCodigoInserido] = useState(0);
  // const [codigoGerado, setcodigoGerado] = useState("");
  const codigoGerado = gerarCodigo();

  function gerarCodigo() {
    var min = 1000000;
    var max = 9999999;
    var num = Math.floor(Math.random() * (max - min + 1) + min);

    return num;
  }

  async function sendCoins2() {
    var userAccount2 = merchantAddress;
    var amount2 = precoProduto2;
    if (typeof window.ethereum !== "undefined") {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(tokenAddress, Token.abi, signer);
      const trasaction = await contract.transfer(userAccount2, amount2);
      await trasaction.wait();
      console.log(`${amount2} Coins successfully sent to ${userAccount2}`);
      // console.log("Coins successfully sent");

      // var codigo = gerarCodigo();

      console.log("Código Gerado: ", codigoGerado);

      document.getElementById("codigoGerado").innerHTML =
        "Código: " + codigoGerado;
    }
  }

  /* ------- Refund ------- */
  const [userAccount_refund, setUserAccount_refund] = useState("");
  const [amount_refund, setAmount_refund] = useState(0);

  async function refund() {
    if (typeof window.ethereum !== "undefined") {
      await requestAccount();
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(tokenAddress, Token.abi, signer);
      const trasaction = await contract.transfer(
        userAccount_refund,
        amount_refund
      );
      await trasaction.wait();
      console.log(
        `${amount_refund} Coins successfully sent to ${userAccount_refund}`
      );
      // console.log("Coins successfully sent");
    }
  }
  /* ---------------------- */

  async function getBalanceBuyer() {
    if (typeof window.ethereum !== "undefined") {
      // const [account] = await window.ethereum.request({
      //   method: "eth_requestAccounts",
      // });
      const account = buyerAddress;
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(tokenAddress, Token.abi, provider);
      const balance = await contract.balanceOf(account);
      // console.log(account, " Balance: ", balance.toString(), "R");
      document.getElementById("buyerBalance2").innerHTML = balance + " R";
    }
  }

  function validarCodigo(numero_inserido, numero_original) {
    if (numero_inserido.toString().length == 7) {
      if (numero_original == numero_inserido) {
        console.log("Código Original: ", numero_original);
        console.log("Código Inserido: ", numero_inserido);

        document.getElementById("validarCodigo").innerHTML = "Valid Code!!";
        document.getElementById("valorInserido").style.display = "none";
      } else
        document.getElementById("validarCodigo").innerHTML = "Invalid Code!!";
    } else document.getElementById("validarCodigo").innerHTML = "";
  }

  /* Código para obter os Dados Através do Bloco/Transação
    let transactionHash =
      "0x60c955508fe805b2214ca3445292950f0ad7f5959a559db0e56bc019f51d1dea";

    provider.getTransaction(transactionHash).then((transaction) => {
      console.log(transaction);
    });

    provider.getTransactionReceipt(transactionHash).then((receipt) => {
      console.log("From: ",receipt.from);
      console.log("To: ",receipt.to);
      console.log("Value: ",receipt.value);
    });
    
    provider.getBlock(block.hash).then((block) => {
      console.log(block);
    });

    //Block Hash
    let blockHash =
      "0x8204d7941ae72844d5d68cdba594b309bb9838bdcabdefd279a76f1ce1cff478";
    provider.getBlock(blockHash).then((block) => {
      console.log("Transactions: ", block.transactions);
      console.log(block);
    });
  */

  /* ------- Obtem Historico Transações ------- */
  /* Original
  function getHistoric_original() {
    // console.log("Historic!");

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    // console.log(
    //   "Nº Total de Blocos: ",
    //   provider.getBlockNumber()
    // );

    // var totalBlocos;

    // provider.getBlock("latest").then((block) => {
    //   console.log("xyz Block Number: ", block.number);
    //   totalBlocos = block.number;
    // });

    // console.log("total Blocks: ", totalBlocos);

    provider.getBlock("latest").then((block) => {
      var a = new Date(block.timestamp * 1000);
      var months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      var year = a.getFullYear();
      var month = months[a.getMonth()];
      var date = a.getDate();
      var hour = a.getHours();
      var min = a.getMinutes();
      var sec = a.getSeconds();
      var time =
        date + "/" + month + "/" + year + " - " + hour + ":" + min + ":" + sec;

      console.log("Block Number: ", block.number);
      console.log("Timestamp: ", time);
      console.log("Hash: ", block.hash);
      console.log("Transactions: ", block.transactions);

      provider.getTransaction(block.transactions[0]).then((receipt) => {
        console.log(receipt);
        console.log("From: ", receipt.from);
        console.log("To: ", receipt.to);
        // console.log("Value: ",receipt.value);
      });
    });

    var array2 = {
      date: "2022",
      from: "apple",
      to: "orange",
      amount: "cherry",
    };
    var text = "";

    // array2.forEach((element) => {
    Object.keys(array2).forEach(() => {
      text += `<tr>
                <td class="center">${array2.date}</td>
                <td class="center">${array2.from}</td>
                <td class="center">${array2.to}</td>
                <td class="center">${array2.amount}</td>
               </tr>`;
    });

    document.getElementById("historicTable").innerHTML =
      `<table style="margin-bottom: 0px">
        <tbody>
          <tr>
            <th class="center">Date</th>
            <th class="center">From</th>
            <th class="center">To</th>
            <th class="center">Amount</th>
          </tr>` +
      text +
      `</tbody>
      </table>`;
  }*/

  function getHistoric() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    provider.getBlock("latest").then((block) => {
      //Converter o timestamp para DD/MM/AA - HH:MM:SS
      var a = new Date(block.timestamp * 1000);
      var months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      var year = a.getFullYear();
      var month = months[a.getMonth()];
      var date = a.getDate();
      var hour = a.getHours();
      var min = a.getMinutes();
      var sec = a.getSeconds();

      if (min < 10) min = "0" + min;
      if (sec < 10) sec = "0" + sec;
      var time =
        date +
        "/" +
        month +
        "/" +
        year +
        "<br/> " +
        hour +
        ":" +
        min +
        ":" +
        sec;

      //Dados Obtidos Através do Nº do Bloco
      console.log("Block Number: ", block.number);
      console.log("Timestamp: ", time);
      console.log("Hash: ", block.hash);
      console.log("Transactions: ", block.transactions);
      console.log("Dados Obtidos Através do Nº do Bloco:", block); //Todos os Dados Obtidos Através do Nº do Bloco

      //Dados Obtidos Através do Hash da Transação
      provider.getTransaction(block.transactions[0]).then((receipt) => {
        console.log("From: ", receipt.from);
        console.log("To: ", receipt.to);
        console.log("Value: ", receipt.value);
        console.log("Dados Obtidos Através do Hash da Transação:", receipt); //Todos os Dados Obtidos Através do Hash da Transação

        var array2 = {
          date: time,
          from: receipt.from,
          to: receipt.to,
          amount: receipt.value + " R",
        };
        var text = "";

        // array2.forEach((element) => {
        // Object.keys(array2).forEach(() => {
        text += `<tr>
                    <td class="center">${array2.date}</td>
                    <td class="center">${array2.from}</td>
                    <td class="center">${array2.to}</td>
                    <td class="center">${array2.amount}</td>
                   </tr>`;
        // });

        document.getElementById("historicTable").innerHTML =
          `<table style="margin-bottom: 0px">
            <tbody>
              <tr>
                <th class="center">Date</th>
                <th class="center">From</th>
                <th class="center">To</th>
                <th class="center">Amount</th>
              </tr>` +
          text +
          `</tbody>
          </table>`;
      });
    });

    /* Exemplo de Iteração com forEach
    var array2 = {
      date: "2022",
      from: "apple",
      to: "orange",
      amount: "cherry",
    };
    var text = "";

    // array2.forEach((element) => {
    Object.keys(array2).forEach(() => {
      text += `<tr>
                <td class="center">${array2.date}</td>
                <td class="center">${array2.from}</td>
                <td class="center">${array2.to}</td>
                <td class="center">${array2.amount}</td>
               </tr>`;
    });

    document.getElementById("historicTable").innerHTML =
      `<table style="margin-bottom: 0px">
        <tbody>
          <tr>
            <th class="center">Date</th>
            <th class="center">From</th>
            <th class="center">To</th>
            <th class="center">Amount</th>
          </tr>` +
      text +
      `</tbody>
      </table>`;*/
  }
  /* ------------------------------------------ */

  return (
    <div className="App">
      <header className="App-header">
        <br />
        {/* ----- Exercicio 1 ----- /}
        <div id="Exercicio_1" className="sideButtons">
          <div style={{ width: "50%" }}>
            <h3>Merchant</h3>
            <table>
              <tbody>
                <tr>
                  <th>Address</th>
                  <td>{merchantAddress}</td>
                </tr>

                <tr>
                  <th>Balance</th>
                  <td id="merchantBalance">{merchantBalance} ETH</td>
                </tr>
              </tbody>
            </table>

            <div style={{ display: "inline-flex" }}>
              <p style={{ marginRight: "10px" }}>NFT: {precoProduto} ETH</p>
              <button className="myButton" onClick={buyProduct}>
                Buy Product
              </button>
            </div>
            <br />
            <br />

            <div>
              <input
                style={{ width: "50%" }}
                className="myInput"
                // onChange={(e) => setUserAccount_refund(e.target.value)}
                placeholder="Buyer Address"
              />
              <input
                style={{ width: "10%" }}
                className="myInput"
                onChange={(e) => setMontanteReembolso(e.target.value)}
                placeholder="R"
              />
              <button className="myInput" onClick={refundBuyer}>
                Refund
              </button>
            </div>
          </div>

          <div className="verticalLine"></div>

          <div style={{ width: "50%" }}>
            <h3>Buyer</h3>
            <table>
              <tbody>
                <tr>
                  <th>Address</th>
                  <td>{buyerAddress}</td>
                </tr>

                <tr>
                  <th>Balance</th>
                  <td id="buyerBalance">{buyerBalance} ETH</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        {/* ----------------------- */}

        {/* <br />
        <hr />
        <br /> */}

        {/* ----- Exercicio 2 ----- /}
        <div id="Exercicio_2">
          <button className="myButton" onClick={fetchGreeting}>
            Get Greeting
          </button>

          <div>
            <input
              className="myInput"
              onChange={(e) => setGreetingValue(e.target.value)}
              placeholder="Set Greeting"
              value={greeting}
            />

            <button className="myButton" onClick={setGreeting}>
              Set Greeting
            </button>
          </div>
        </div>
        {/* ----------------------- */}

        {/* <br />
        <hr />
        <br /> */}

        {/* ----- Exercicio 3 ----- /}
        <div id="Exercicio_3">
          <button className="myInput" onClick={getBalance}>
            Get Balance
          </button>
          <div>
            <input
              className="myInput"
              onChange={(e) => setUserAccount(e.target.value)}
              placeholder="Account ID"
            />
            <input
              className="myInput"
              onChange={(e) => setAmount(e.target.value)}
              placeholder="Amount"
            />
            <button className="myInput" onClick={sendCoins}>
              Send Coins
            </button>
          </div>
        </div>
        {/* ----------------------- */}

        {/* <br />
        <hr />
        <br /> */}
        <br />
        <br />

        {/* ----- Exercicio 4 ----- */}
        <div id="Exercicio_4" className="sideButtons">
          <div style={{ width: "50%" }}>
            <h3>Merchant</h3>
            <table>
              <tbody>
                <tr>
                  <th>Address</th>
                  <td>{merchantAddress}</td>
                </tr>

                <tr>
                  <th>
                    <button className="myInput" onClick={getBalanceMerchant}>
                      Balance
                    </button>
                  </th>
                  <td id="merchantBalance2">R</td>
                </tr>
              </tbody>
            </table>

            <div style={{ display: "inline-flex" }}>
              <p style={{ marginRight: "10px" }}>NFT: {precoProduto2} R</p>
              <button className="myButton" onClick={sendCoins2}>
                Buy Product
              </button>
              <p id="codigoGerado" style={{ marginLeft: "10px" }}></p>
            </div>
            {/* Refund */}
            <br />
            <br />
            <div>
              <input
                style={{ width: "50%" }}
                className="myInput"
                onChange={(e) => setUserAccount_refund(e.target.value)}
                placeholder="Buyer Address"
              />
              <input
                style={{ width: "10%" }}
                className="myInput"
                onChange={(e) => setAmount_refund(e.target.value)}
                placeholder="R"
              />
              <button className="myInput" onClick={refund}>
                Refund
              </button>
            </div>
          </div>

          <div className="verticalLine"></div>

          <div style={{ width: "50%" }}>
            <h3>Buyer</h3>
            <table>
              <tbody>
                <tr>
                  <th>Address</th>
                  <td>{buyerAddress}</td>
                </tr>

                <tr>
                  <th>
                    <button className="myInput" onClick={getBalanceBuyer}>
                      Balance
                    </button>
                  </th>
                  <td id="buyerBalance2">R</td>
                </tr>
              </tbody>
            </table>

            <div>
              <input
                style={{ width: "20%" }}
                className="myInput"
                // onChange={(e) => setCodigoInserido(e.target.value)}
                onChange={(e) => validarCodigo(e.target.value, codigoGerado)}
                placeholder="Code"
                id="valorInserido"
              />
              {/* <button className="myInput" onClick={validarCodigo(codigoGerado)}>
                Check
              </button> */}
            </div>
            <p id="validarCodigo"></p>
          </div>
        </div>

        <br />
        <br />

        <div
          id="Exercicio_4_Historic"
          style={{ display: "-webkit-inline-box", width: "80%" }}
        >
          <button
            style={{ marginBottom: "20px" }}
            className="myInput"
            onClick={getHistoric}
          >
            Historic
          </button>
        </div>

        <div style={{ width: "80%" }} id="historicTable"></div>
        {/* ----------------------- */}
      </header>
    </div>
  );
}

export default App;
