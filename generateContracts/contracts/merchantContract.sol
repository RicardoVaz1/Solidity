// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";


contract MerchantContract {
    // VARIABLES
    /* ----- SYSTEM ----- */
    address private owner_address;
    bool public system_state; // true = paused; false = unpased

    event PausedMerchant(uint256 DATE, address MERCHANT_ADDRESS, bool SYSTEM_STATE);
    event UnpausedMerchant(uint256 DATE, address MERCHANT_ADDRESS, bool SYSTEM_STATE);
    event DeletedMerchant(uint256 DATE, address MERCHANT_ADDRESS);
    /* ------------------ */

    /* ----- MERCHANT ----- */
    address public merchant_address;
    uint256 public merchant_balance;
    string public merchant_name;
    bool public merchant_state;
    
    address public buyer_address;
    uint256 public amount;

    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }
    State public currsState;

    event ChangedMerchantAddress(uint256 DATE, address MERCHANT_ADDRESS, address NEW_MERCHANT_ADDRESS);
    // Date | Transaction_Type | From | To | Value | Status
    event Deposited(uint256 DATE, string TRANSACTION_TYPE, address BUYER_ADDRESS, address MERCHANT_ADDRESS, uint256 AMOUNT, string STATUS);
    event Sell(uint256 DATE, string TRANSACTION_TYPE, address BUYER_ADDRESS, address MERCHANT_ADDRESS, uint256 AMOUNT, string STATUS);
    event Refund(uint256 DATE, string TRANSACTION_TYPE, address MERCHANT_ADDRESS, address BUYER_ADDRESS, uint256 AMOUNT, string STATUS);
    

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }
    /* -------------------- */



    // FUNCTIONS
    constructor(address OWNER_ADDRESS, address MERCHANT_ADDRESS, uint256 MERCHANT_BALANCE, string memory MERCHANT_NAME, bool MERCHANT_STATE) {
        owner_address = OWNER_ADDRESS;
        merchant_address = MERCHANT_ADDRESS;
        merchant_balance = MERCHANT_BALANCE;
        merchant_name = MERCHANT_NAME;
        merchant_state = MERCHANT_STATE;
    }

    /* ----- SYSTEM ----- */
    function pauseMerchant(address OWNER_ADDRESS) public {
        require(owner_address == OWNER_ADDRESS, "Only Owner can call this function");

        system_state = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(block.timestamp, merchant_address, system_state);
    }

    function unpauseMerchant(address OWNER_ADDRESS) public {
        require(owner_address == OWNER_ADDRESS, "Only Owner can call this function");
        
        system_state = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit UnpausedMerchant(block.timestamp, merchant_address, system_state);
    }

    function deleteMerchant(address OWNER_ADDRESS) public {
        require(owner_address == OWNER_ADDRESS, "Only Owner can call this function");
        
        delete merchant_address;
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(block.timestamp, merchant_address);
    }
    /* ------------------ */




    /* ----- MERCHANT ----- */
    function changeMerchantAddress(address NEW_MERCHANT_ADDRESS) public virtual onlyMerchant {
        emit ChangedMerchantAddress(block.timestamp, merchant_address, NEW_MERCHANT_ADDRESS);
        merchant_address = NEW_MERCHANT_ADDRESS;
        console.log("New Merchant adress is: ", merchant_address);
    }

    // ESCROW
    function deposit() public payable {
        require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(currsState == State.AWAITING_PAYMENT, "Already paid!");
        require(msg.value * (1 ether) > 0, "Deposit amount should be >0!");

        buyer_address = msg.sender;
        amount = msg.value;

        // Date | Transaction_Type | From | To | Value | Status
        emit Deposited(block.timestamp, "Deposit", buyer_address, merchant_address, amount, "Complete");
        
        // Waiting x blocks before send the money to Merchant
        /* ... */

        console.log("Time: ", block.timestamp);
        console.log("Transaction Type: ", "Deposit");
        console.log("From: ", buyer_address, "(Buyer)");
        console.log("To: ", merchant_address, "(Merchant)" );
        console.log("Value: ", amount);
        console.log("Status: ", "Complete");

        currsState = State.WAIT_A_MOMENT;
        //transactionSucess(buyer_address, amount);
    }

    function transactionSucess() public payable { //private
        //buyer_address = BUYER_ADDRESS;
        //amount = AMOUNT;

        require(currsState == State.WAIT_A_MOMENT, "Need to make the deposit first!");
        payable(merchant_address).transfer(amount);
        currsState = State.COMPLETE;

        // Date | Transaction_Type | From | To | Value | Status
        emit Sell(block.timestamp, "Sell", buyer_address, merchant_address, amount, "Complete");
        
        console.log("Time: ", block.timestamp);
        console.log("Transaction Type: ", "Sell");
        console.log("From: ", buyer_address, "(Buyer)");
        console.log("To: ", merchant_address, "(Merchant)");
        console.log("Value: ", amount);
        console.log("Status: ", "Complete");
    }


    // REFUNDS
    function refund(address BUYER_ADDRESS) onlyMerchant public payable {
        //require(msg.value == amount, "Wrong refund amount!");
        require(msg.value * (1 ether) > 0, "Refund amount should be >0!");

        buyer_address = BUYER_ADDRESS;
        amount = msg.value;
        
        payable(buyer_address).transfer(amount);

        // Date | Transaction_Type | From | To | Value | Status
        emit Refund(block.timestamp, "Refund", merchant_address, buyer_address, amount, "Complete");

        console.log("Time: ", block.timestamp);
        console.log("Transaction Type: ", "Refund");
        console.log("From: ", merchant_address, "(Merchant)");
        console.log("To: ", buyer_address, "(Buyer)");
        console.log("Value: ", amount);
        console.log("Status: ", "Complete");
    }
    /* -------------------- */
}