// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;

import "./Libraries.sol";
import "hardhat/console.sol";

abstract contract MainContract {
    // VARIABLES
    using SafeMath for uint256;
    using Address for address payable;

    mapping (address => uint256) private balances;

    address public owner_address = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148; // Owner of DApp (could be a DAO)

    uint8 public decimals = 18;

    event OwnershipTransferred(address OWNER_ADDRESS, address NEW_OWNER);
    event Paused(address ACCOUNT_ADDRESS);
    event Unpaused(address ACCOUNT_ADDRESS);
    event RemovedMerchant(address ACCOUNT_ADDRESS);


    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }


    // FUNCTIONS
    function pause(address ACCOUNT_ADDRESS) public virtual onlyOwner {
        emit Paused(ACCOUNT_ADDRESS);
        console.log("Paused: ", ACCOUNT_ADDRESS);
    }

    function unpause(address ACCOUNT_ADDRESS) public virtual onlyOwner {
        emit Unpaused(ACCOUNT_ADDRESS);
        console.log("Not Paused: ", ACCOUNT_ADDRESS);
    }

    function removeMerchant(address ACCOUNT_ADDRESS) public virtual onlyOwner {
        emit RemovedMerchant(ACCOUNT_ADDRESS);
        console.log("Merchant Removed: ", ACCOUNT_ADDRESS);
    }

    function balanceOf(address ACCOUNT_ADDRESS) public view onlyOwner returns (uint256) {
        console.log("Account: ", ACCOUNT_ADDRESS);
        console.log("Balance: ", balances[ACCOUNT_ADDRESS]);

        return balances[ACCOUNT_ADDRESS];
    }

    function transferOwnership(address NEW_OWNER) public virtual onlyOwner {
        emit OwnershipTransferred(owner_address, NEW_OWNER);
        owner_address = NEW_OWNER;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }
}


abstract contract MerchantContract is MainContract {
    // VARIABLES
    address public merchant_address;
    event ChangedMerchantAdress(address merchant_address, address NEW_MERCHANT_ADDRESS);


    // MODIFIERS
    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }


    // FUNCTIONS
    constructor() {
        merchant_address = msg.sender;
    }

    function changeMerchantAdress(address NEW_MERCHANT_ADDRESS) public virtual onlyMerchant {
        emit ChangedMerchantAdress(merchant_address, NEW_MERCHANT_ADDRESS);
        merchant_address = NEW_MERCHANT_ADDRESS;
        console.log("New Merchant adress is: ", merchant_address);
    }
}


contract Escrow is MerchantContract {
    // VARIABLES
    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }
    State public currsState;

    address public buyer_address;
    uint256 public amount;

    // Date | Transaction_Type | From | To | Value | Status
    event Deposited(uint256 DATE, string TRANSACTION_TYPE, address BUYER_ADDRESS, address MERCHANT_ADDRESS, uint256 AMOUNT, string STATUS);
    event Sell(uint256 DATE, string TRANSACTION_TYPE, address BUYER_ADDRESS, address MERCHANT_ADDRESS, uint256 AMOUNT, string STATUS);


    // MODIFIERS
    /*modifier onlyBuyer() {
        require(msg.sender == buyer_address, "Only Buyer can call this funcion");
        _;
    }*/


    // FUNCTIONS
    /*constructor(address BUYER_ADDRESS, uint256 DEPOSIT) {
        buyer_address = BUYER_ADDRESS;
        amount = DEPOSIT * (1 ether);
    }*/

    function deposit() public payable {
        require(msg.sender != merchant_address && msg.sender != owner_address, "Only Buyer can call this funcion");
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

    function transactionSucess(address BUYER_ADDRESS, uint256 AMOUNT) private {
        buyer_address = BUYER_ADDRESS;
        amount = AMOUNT;

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
}


contract Refunds is MerchantContract {
    // VARIABLES
    address public buyer_address;
    uint256 public amount;

    // Date | Transaction_Type | From | To | Value | Status
    event Refund(uint256 DATE, string TRANSACTION_TYPE, address MERCHANT_ADDRESS, address BUYER_ADDRESS, uint256 AMOUNT, string STATUS);
    
    
    // FUNCTIONS
    /*constructor(address BUYER_ADDRESS, uint256 REFUND) {
        buyer_address = BUYER_ADDRESS;
        amount = REFUND * (1 ether);
    }*/
    
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
}