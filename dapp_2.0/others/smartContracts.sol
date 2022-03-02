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

    // VARIABLES
    enum Transaction_Type { Sell, Refund }
    enum Status { Pending, Complete }

    struct transactionStruct {
        uint256 Date;

        Transaction_Type currentType;

        address From;
        address To;

        uint256 Value;

        Status currentStatus;
    }

    transactionStruct transaction;

    address merchant;


    // MODIFIERS
    modifier onlyMerchant() {
        require(msg.sender == merchant, "Only Merchant can call this function");
        _;
    }


    // FUNCTIONS
    function getHistoric() onlyMerchant public {
        if(transaction.From == merchant) transaction.currentType = Transaction_Type.Refund;
        if(transaction.To == merchant) transaction.currentType = Transaction_Type.Sell;

        /*const provider = new ethers.providers.Web3Provider(window.ethereum);

        provider.getBlock("latest").then((block) => {
            //Convert the timestamp to DD/MM/AA - HH:MM:SS
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

            //Data Obtained Through Block Nº
            console.log("Block Number: ", block.number);
            console.log("Timestamp: ", time);
            console.log("Hash: ", block.hash);
            console.log("Transactions: ", block.transactions);
            console.log("Data Obtained Through Block Nº:", block); //All Data Obtained Through Block Nº

            //Data Obtained Through Transaction Hash
            provider.getTransaction(block.transactions[0]).then((receipt) => {
                console.log("From: ", receipt.from);
                console.log("To: ", receipt.to);
                console.log("Value: ", receipt.value);
                console.log("Data Obtained Through Transaction Hash:", receipt); //All Data Obtained Through Transaction Hash

                var array = {
                date: time,
                //type: transaction_type,
                from: receipt.from,
                to: receipt.to,
                value: receipt.value + " ETH",
                //status: transaction_status,
                };
                var text = "";

                text += `<tr>
                            <td class="center">${array.date}</td>
                            //<td class="center">${array.type}</td>
                            <td class="center">${array.from}</td>
                            <td class="center">${array.to}</td>
                            <td class="center">${array.value}</td>
                            //<td class="center">${array.status}</td>
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
    // VARIABLES
    address payable buyer;
    address payable merchant;
    uint value;


    // MODIFIERS
    modifier onlyMerchant() {
        require(msg.sender == merchant, "Only Merchant can call this function");
        _;
    }


    // FUNCTIONS
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