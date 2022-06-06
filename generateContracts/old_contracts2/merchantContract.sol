// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

contract MerchantContract {
    /* ========== SYSTEM ========== */
    address private owner_address;

    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }


    /* ========== MERCHANT ========== */
    address public merchant_address;   // buyers will be sending the money to merchantContract_address and then the money will be sent to this address
    string public name;
    uint256 public escrow_amount;     // amount waiting for escrow_time to end to be added to balance
    uint256 public balance;           // amount verified and ready to sendToMerchant

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }



    /* ========== BUYERs ========== */
    /*struct Buyer {
        uint id;
        address _address;
    }

    uint public buyersCount; // count the nº of buyers
    mapping(uint => Buyer) public buyers;*/


    /* ========== PURCHASEs ========== */
    // List of Purchases Created by Merchant
    struct PurchasesCreated {
        uint id;
        uint idPurchase;
        uint256 amount;
    }

    uint public purchasesCounter; // count the nº of purchases created by Merchant
    mapping(uint => PurchasesCreated) public purchasesCreated;


    // List of Buyers Purchases
    struct Purchase {
        uint id;
        uint idPurchase;
        uint256 dateI;
        uint256 dateF;
        uint256 amount;
        bool finished; // true: finished; false: not finished
    }

    uint public purchasesCount; // count the nº of buyers purchases
    mapping(uint => Purchase) public purchases;

    
    uint public escrow_time; // time the merchant has to wait, for the money to be sent to his wallet



    /* ========== CONSTRUCTOR ========== */
    constructor(address OwnerAddress, address MerchantAddress, string memory MerchantName) {
        owner_address = OwnerAddress;

        merchant_address = MerchantAddress;
        name = MerchantName;
        escrow_amount = 0;
        balance = 0;
        
        // buyersCount = 0;
        purchasesCounter = 0;
        purchasesCount = 0;

        escrow_time = 259200; // default: 3 days = 259200 seconds
    }


    /* ========== SYSTEM ========== */
    function getMerchantAddress() public view /*onlyOwner*/ returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }
    
    function changeEscrowTime(uint NewEscrowTime) public /*onlyOwner*/ {
        emit ChangedEscrowTime(NewEscrowTime);
        escrow_time = NewEscrowTime;
        console.log("New escrow time is: ", escrow_time);
    }

    function complete(uint PurchaseID) public onlyOwner {
        escrow_amount -= purchases[PurchaseID].amount;
        balance += purchases[PurchaseID].amount;

        console.log("Puchase w/ id ", purchases[PurchaseID].id, " was completed!");
        console.log("EscrowAmount: ", escrow_amount);
        console.log("Balance: ", balance);

        emit Complete(PurchaseID, escrow_amount, balance);
    }

    function sendToMerchant() public payable onlyOwner {
        require(balance > 0, "Merchant balance should be >0!!");

        payable(merchant_address).transfer(balance);
        // payable(merchant_address).transfer(msg.value);

        console.log("Address: ", merchant_address);
        console.log("Balance Sent: ", balance);

        emit SendToMerchant(merchant_address, balance);

        balance = 0;
        // console.log("Update balance: ", balance);
    }



    /* ========== MERCHANTs ========== */
    function createPurchase(uint idPurchase, uint256 purchaseAmount) public onlyMerchant {
        purchasesCreated[purchasesCounter] = PurchasesCreated(purchasesCounter, idPurchase, purchaseAmount);
        purchasesCounter++;

        console.log("Puchase w/ id ", idPurchase);
        console.log(" and amount ", purchaseAmount, " was created!");
    }


    function refund(address BuyerAddress, uint256 refundAmount) public payable onlyMerchant {
        require(refundAmount > 0, "Amount should be >0!!");

        // escrow_amount -= refundAmount;
        // console.log("EscrowAmount: ", escrow_amount);

        payable(BuyerAddress).transfer(refundAmount);
        // payable(BuyerAddress).transfer(msg.value);

        console.log("Address: ", BuyerAddress);
        console.log("Address: ", refundAmount);

        // To | Amount
        emit Refund(BuyerAddress, refundAmount);
    }



    /* ========== BUYERs ========== */
    function buy(uint idPurchase, uint purchaseAmount) public {
        require(purchaseAmount > 0, "Amount should be >0!");

        if(verifyIFpurchaseExist(idPurchase, purchaseAmount) == false) {
            // true: purchase exist; false: purchase doesn't exist
            console.log("This purchase wasn't created by Merchant!");
            return;
        }

        if(verifyIFpurchaseISpaid(idPurchase) == true) {
            // true: purchase paid; false: purchase not paid
            console.log("This purchase has already been paid!");
            return;
        }

        // createBuyer(msg.sender);

        uint256 dateI = block.timestamp;
        uint256 dateF = dateI + escrow_time;

        escrow_amount += purchaseAmount;
        console.log("EscrowAmount: ", escrow_amount);
        
        purchases[purchasesCount] = Purchase(purchasesCount, idPurchase, dateI, dateF, purchaseAmount, true);

        // ID | DateI | DateF | From | To | Amount
        emit Buy(purchasesCount, dateI, dateF, msg.sender, merchant_address, purchaseAmount);
        purchasesCount++;
    }

    /*function createBuyer(address BuyerAddress) private {
        buyers[buyersCount] = Buyer(buyersCount, BuyerAddress);
        buyersCount++;

        console.log("Buyer ", BuyerAddress, " created!");
    }*/

    function verifyIFpurchaseExist(uint idPurchase, uint256 amount) private view returns(bool) {
        // verify if the purchase w/ those parameters exist on the list of Purchases Created by Merchant
        for(uint i = 0; i <= purchasesCounter; i++) {
            if(idPurchase == purchasesCreated[i].idPurchase && amount == purchasesCreated[i].amount) {
                // Purchase exist
                return true;
            }
        }
        return false;
    }

    function verifyIFpurchaseISpaid(uint idPurchase) private view returns(bool) {
        // verify in the Purchases list if that purchase has already been finished
        for(uint i = 0; i <= purchasesCount; i++) {
            if(idPurchase == purchases[i].idPurchase && purchases[i].finished == true) {
                // Purchase is paid
                return true;
            }
        }
        return false;
    }



    /* ========== EVENTS ========== */
    event ChangedEscrowTime(uint NewEscrowTime);

    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateI, uint256 DateF, address BuyerAddress, address MerchantAddress, uint256 Amount);
    event Complete(uint PurchaseID, uint256 EscrowAmount, uint256 Balance);
    event SendToMerchant(address MerchantAddress, uint256 Amount);
    event Refund(address BuyerAddress, uint256 Amount);
}