// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;


contract Escrow {

    // VARIABLES
    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }

    State public currsState;

    address buyer;
    address payable merchant;

    uint price;
    uint i;


    /*uint256 public z_startingTime;
    uint256 public z_endingTime;
    uint256 public z_actualTime = block.timestamp;*/



    // MODIFIERS
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only Buyer can call this function");
        _;
    }



    // FUNCTIONS
    constructor(address buyer_address, address payable merchant_address, uint product_price){
        buyer = buyer_address;
        merchant = merchant_address;
        price = product_price * (1 ether);
    }

    function deposit() onlyBuyer public payable {
        require(currsState == State.AWAITING_PAYMENT, "Already paid");
        require(msg.value == price, "Wrong deposit amount");
        
        // Waiting x blocks before send the money to Merchant
        /*startingTime = block.timestamp;
        endingTime = startingTime + 10; // 1 minute
        i = 1;

        while(i == 1) {
            if(block.timestamp >= endingTime) i = 2;
        }*/

        currsState = State.WAIT_A_MOMENT;
        transactionSucess();
    }

    function transactionSucess() private {
        require(currsState == State.WAIT_A_MOMENT, "Not in the corect stage!");        
        //merchant.transfer(price);
        payable(merchant).transfer(msg.value);
        currsState = State.COMPLETE;
    }
}

contract Historic {

    // Date | Transaction_Type | From | To | Value | Status

    uint256 Date;

    enum Type { Sell, Refund }
    Type currentType;

    address From;
    address To;

    uint256 Value;

    enum Status { Pending, Complete }
    Status currentStatus;

    address merchant;


    modifier onlyMerchant() {
        require(msg.sender == merchant, "Only Merchant can call this function");
        _;
    }

    function getHistoric() onlyMerchant public {
        /*const provider = new ethers.providers.Web3Provider(window.ethereum);

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
            //type: transaction_type,
            from: receipt.from,
            to: receipt.to,
            value: receipt.value + " ETH",
            //status: transaction_status,
            };
            var text = "";

            text += `<tr>
                        <td class="center">${array2.date}</td>
                        //<td class="center">${array2.type}</td>
                        <td class="center">${array2.from}</td>
                        <td class="center">${array2.to}</td>
                        <td class="center">${array2.value}</td>
                        //<td class="center">${array2.status}</td>
                    </tr>`;

            document.getElementById("historicTable").innerHTML =
            `<table style="margin-bottom: 0px">
                <tbody>
                <tr>
                    <th class="center">Date</th>
                    //<th class="center">Type</th>
                    <th class="center">From</th>
                    <th class="center">To</th>
                    <th class="center">Value</th>
                    //<th class="center">Status</th>
                </tr>` +
            text +
            `</tbody>
            </table>`;
        });
        });
        */
    }
}

contract Refunds {

    address payable buyer;
    address payable merchant;
    uint value;

    modifier onlyMerchant() {
        require(msg.sender == merchant, "Only Merchant can call this function");
        _;
    }


    
    constructor(address payable buyer_address, address payable merchant_address, uint refund_value){
        buyer = buyer_address;
        merchant = merchant_address;
        value = refund_value * (1 ether);
    }
    
    function refund() onlyMerchant public payable {
        require(msg.value > 0, "Minimum 1 ETH");
        require(msg.value == value, "Wrong amount!");
        buyer.transfer(msg.value);
    }
}