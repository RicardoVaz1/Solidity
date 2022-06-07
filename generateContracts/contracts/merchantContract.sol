// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MerchantContract is Ownable {
    /* ========== SYSTEM ========== */
    // address private owner_address;
    bool public paused; // true = paused; false = unpaused

    /*modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }*/

    modifier systemState() {
        require(paused == false, "The system is paused!");
        _;
    }



    /* ========== MERCHANT ========== */
    address payable private merchant_address;   // buyers will be sending the money to merchantContract_address and then the money will be sent to this address
    string public name;
    uint256 private escrow_amount;              // amount waiting for escrow_time to end to be added to balance
    uint256 private balance;                    // amount verified and ready to sendToMerchant

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }



    /* ========== PURCHASEs ========== */
    struct Purchase {
        uint256 dateF;
        uint256 amount;
        uint status; // 0: default, purchase wasn't created; 1: purchase created, but not paid; 2: purchase created and paid
    }

    // idPurchase => Purchase
    mapping(uint => Purchase) public purchases;

    
    uint public escrow_time; // time the merchant has to wait, for the money to be sent to his wallet



    /* ========== CONSTRUCTOR ========== */
    constructor(/*address OwnerAddress,*/ address payable MerchantAddress, string memory MerchantName) {
        // owner_address = OwnerAddress;

        merchant_address = MerchantAddress;
        name = MerchantName;
        escrow_amount = 0;
        balance = 0;
        
        escrow_time = 259200; // default: 3 days = 259200 seconds
        paused = false;
    }


    /* ========== SYSTEM ========== */
    function getMerchantAddress() public view onlyOwner returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }
    
    function changeEscrowTime(uint NewEscrowTime) public onlyOwner {
        escrow_time = NewEscrowTime;
        console.log("New escrow time is: ", escrow_time);
        emit ChangedEscrowTime(escrow_time);
    }

    function pauseMerchant() public onlyOwner {
        paused = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(address(this), paused);
    }

    function unpauseMerchant() public onlyOwner {
        paused = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit PausedMerchant(address(this), paused);
    }

    function deleteMerchant() public onlyOwner {
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(address(this));
        delete merchant_address;
    }



    /* ========== MERCHANTs ========== */
    function checkMyAddress() public view onlyMerchant returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }

    function changeMyAddress(address payable NewAddress) public onlyMerchant {
        merchant_address = NewAddress;
        console.log("New Merchant Address is: ", merchant_address);
        // emit ChangedMyAddress(merchant_address);
    }

    function checkMyEscrowAmount() public view onlyMerchant returns(uint256) {
        console.log("Merchant EscrowAmount: ", escrow_amount);
        return escrow_amount;
    }

    function checkMyBalance() public view onlyMerchant returns(uint256) {
        console.log("Merchant Balance: ", balance);
        return balance;
    }

    function createPurchase(uint idPurchase, uint256 purchaseAmount) public onlyMerchant {
        uint256 dateF = block.timestamp + escrow_time;
        purchases[idPurchase] = Purchase(dateF, purchaseAmount, 1);

        console.log("Puchase w/ id ", idPurchase);
        console.log(" and amount ", purchaseAmount, " was created!");
    }

    function complete(uint idPurchase) public onlyMerchant {
        require(purchases[idPurchase].dateF < block.timestamp, "The escrow time of this purchase isn't over yet!");

        escrow_amount -= purchases[idPurchase].amount;
        balance += purchases[idPurchase].amount;

        console.log("Puchase w/ id ", idPurchase, " was completed!");
        console.log("EscrowAmount: ", escrow_amount);
        console.log("Balance: ", balance);

        emit Complete(idPurchase);
    }

    function sendToMerchant() public onlyMerchant systemState {
        require(balance > 0, "Balance should be greater than 0!!");

        merchant_address.transfer(balance);

        console.log("Address: ", merchant_address);
        console.log("Balance Sent: ", balance);

        // emit SendToMerchant(merchant_address, balance);
        balance = 0;
    }

    function refund(uint idPurchase, address payable BuyerAddress, uint256 refundAmount) public onlyMerchant {
        require(refundAmount > 0, "Refund amount should be greater than 0!!");
        require(refundAmount <= purchases[idPurchase].amount, "Refund amount shouldn't be greater than the purchaseAmount!");

        // if(escrow_amount < refundAmount) revert("You don't have enough money in the smart-contract!");
        if(address(this).balance < refundAmount) revert("You don't have enough money in the smart-contract!");

        if(escrow_amount >= refundAmount) {
            escrow_amount -= refundAmount;
            console.log("EscrowAmount updated!");
        }
        else if(balance >= refundAmount) {
            balance -= refundAmount;
            console.log("Balance updated!");
        }
        else revert("Error processing refund, check your smart-contract balance!");

        BuyerAddress.transfer(refundAmount);       

        console.log("idPurchase: ", idPurchase);
        console.log("Address: ", BuyerAddress);
        console.log("RefundAmount: ", refundAmount);

        // From | To | Amount
        emit Refund(address(this), BuyerAddress, refundAmount);
    }



    /* ========== BUYERs ========== */
    function buy(uint idPurchase) external payable systemState {
        if(msg.value == 0) revert("Amount should be greater than 0!");
        
        if(purchases[idPurchase].status == 0) revert("Purchase doesn't exist!"); // By default status is 0
        // if(purchases[idPurchase].status == 1) revert("Purchase isn't paid!");
        if(purchases[idPurchase].status == 2) revert("Purchase is paid!");
        if(msg.value != purchases[idPurchase].amount) revert("Wrong amount!");

        escrow_amount += msg.value;
        console.log("EscrowAmount: ", escrow_amount);
        
        purchases[idPurchase].status = 2;

        // ID | DateF | From | To | Amount
        emit Buy(idPurchase, purchases[idPurchase].dateF, msg.sender, address(this), msg.value);
    }


    /* ========== EVENTS ========== */
    event ChangedEscrowTime(uint NewEscrowTime);
    event PausedMerchant(address MerchantContractAddress, bool SystemState); // true = paused; false = unpaused
    event DeletedMerchant(address MerchantContractAddress);
    // event ChangedMyAddress(NewAddress);

    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateF, address BuyerAddress, address MerchantContractAddress, uint256 Amount);
    event Complete(uint PurchaseID);
    // event SendToMerchant(address MerchantAddress, uint256 Balance);
    event Refund(address MerchantContractAddress, address BuyerAddress, uint256 Amount);
}