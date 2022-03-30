// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MerchantContract {
    // VARIABLES
    /* ----- SYSTEM ----- */
    address private owner_address;
    bool public paused; // true = paused; false = unpaused

    event PausedMerchant(uint256 Date, address Merchant_Address, bool System_State); // true = paused; false = unpaused
    event DeletedMerchant(uint256 Date, address Merchant_Address);

    modifier systemState() {
        require(paused == false, "The system is Paused!");
        _;
    }
    /* ------------------ */


    /* ----- MERCHANT ----- */
    address public merchant_address;
    uint256 public merchant_balance;
    string public merchant_name;
    //bool public merchant_state;
    
    event ChangedMerchantAddress(uint256 Date, address Merchant_Address, address New_Merchant_Address);
    event Refund(uint256 Date, uint ID, string Transaction_Type, address Merchant_Address, address Buyer_Address, uint256 Amount, string Status); // Date | ID | Transaction_Type | From | To | Value | Status


    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }
    /* -------------------- */



    /* ----- BUYERs ----- */
    //address public buyer_address;
    //uint256 public amount;

    mapping (uint => address) buyersAccounts_Addresses;
    mapping (address => uint256) buyersAccounts_Amounts;

    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }
    State private currsState;

    mapping (address => State) buyersAccounts_States;
    uint256 buyersAccounts_Counter;

    using Counters for Counters.Counter;
    Counters.Counter private Purchase_ID;
    
    uint256 newPurchase_ID;
    
    
    // Date | ID | Transaction_Type | From | To | Value | Status
    event Deposited(uint256 Date, uint ID, string Transaction_Type, address Buyer_Address, address Merchant_Address, uint256 Amount, string Status);
    event Sell(uint256 Date, uint ID, string Transaction_Type, address Buyer_Address, address Merchant_Address, uint256 Amount, string Status);
    /* ------------------ */



    // FUNCTIONS
    constructor(address Owner_Address, address Merchant_Address, uint256 Merchant_Balance, string memory Merchant_Name, bool Merchant_State) {
        owner_address = Owner_Address;
        merchant_address = Merchant_Address;
        merchant_balance = Merchant_Balance;
        merchant_name = Merchant_Name;
        paused = Merchant_State;

        buyersAccounts_Counter = 0;
    }

    /* ----- SYSTEM ----- */
    function pauseMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");

        paused = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(block.timestamp, merchant_address, paused);
    }

    function unpauseMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");
        
        paused = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit PausedMerchant(block.timestamp, merchant_address, paused);
    }

    function deleteMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");
        
        delete merchant_address;
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(block.timestamp, merchant_address);
    }
    /* ------------------ */




    /* ----- MERCHANT ----- */
    function changeMerchantAddress(address New_Merchant_Address) public virtual onlyMerchant systemState {
        emit ChangedMerchantAddress(block.timestamp, merchant_address, New_Merchant_Address);
        merchant_address = New_Merchant_Address;
        console.log("New Merchant adress is: ", merchant_address);
    }

    // REFUNDS
    function refund(address Buyer_Address, uint256 ID) public payable onlyMerchant systemState {
        require(msg.value * (1 ether) > 0, "Refund amount should be >0!");

        // buyer_address = Buyer_Address;
        // amount = msg.value;

        payable(Buyer_Address).transfer(msg.value);

        // Date | ID | Transaction_Type | From | To | Value | Status
        emit Refund(block.timestamp, ID, "Refund", merchant_address, Buyer_Address, msg.value, "Complete");

        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", ID);
        console.log("Transaction Type: ", "Refund");
        console.log("From: ", merchant_address, "(Merchant)");
        console.log("To: ", Buyer_Address, "(Buyer)");
        console.log("Value: ", msg.value);
        console.log("Status: ", "Complete");
    }
    /* -------------------- */



    /* ----- BUYERs ----- */
    // ESCROW
    function deposit() public payable systemState {
        require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(buyersAccounts_States[msg.sender] == State.AWAITING_PAYMENT, "Already paid!");
        require(msg.value * (1 ether) > 0, "Deposit amount should be >0!");


        //buyer_address = msg.sender;
        //amount = msg.value;

        if(verifyBuyerAddress(msg.sender) == true) {
            buyersAccounts_Addresses[buyersAccounts_Counter] = msg.sender;
            buyersAccounts_Counter += 1;
            //console.log("Buyer Added!");
        }

        buyersAccounts_Amounts[msg.sender] = msg.value;
        
        Purchase_ID.increment();
        newPurchase_ID = Purchase_ID.current();


        // Date | Transaction_Type | From | To | Value | Status
        emit Deposited(block.timestamp, newPurchase_ID, "Deposit", msg.sender, merchant_address, msg.value, "Complete");
        
        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", newPurchase_ID);
        console.log("Transaction Type: ", "Deposit");
        console.log("From: ", msg.sender, "(Buyer)");
        console.log("To: ", merchant_address, "(Merchant)");
        console.log("Value: ", msg.value);
        console.log("Status: ", "Complete");


        // Waiting x blocks before send the money to Merchant
        /* ... */

        //currsState = State.WAIT_A_MOMENT;
        buyersAccounts_States[msg.sender] = State.WAIT_A_MOMENT;

        //transactionSucess(msg.sender, msg.value, newPurchase_ID);
    }

    function verifyBuyerAddress(address Buyer_Address) view private returns(bool) {
        for(uint i = 0; i < buyersAccounts_Counter; i++) {
            if(Buyer_Address == buyersAccounts_Addresses[i]) {
                console.log("This Address already exists in the system!");
                return false;
            }
        }
        console.log("Buyer verified!");
        return true;
    }

    function transactionSucess(address Buyer_Address, uint256 Amount, uint256 ID) private systemState {
        require(buyersAccounts_States[Buyer_Address] == State.WAIT_A_MOMENT, "Need to make the deposit first!");
        
        // buyer_address = Buyer_Address;
        // amount = Amount;

        payable(merchant_address).transfer(Amount);
        buyersAccounts_States[Buyer_Address] = State.COMPLETE;

        // Date | ID | Transaction_Type | From | To | Value | Status
        emit Sell(block.timestamp, ID, "Sell", Buyer_Address, merchant_address, Amount, "Complete");
        
        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", ID);
        console.log("Transaction Type: ", "Sell");
        console.log("From: ", Buyer_Address, "(Buyer)");
        console.log("To: ", merchant_address, "(Merchant)");
        console.log("Value: ", Amount);
        console.log("Status: ", "Complete");
    }
    /* ------------------ */


    // To use USDC/USDT/DAI Token
    function depo(uint256 amount) external {
        // Get Contract Address from https://etherscan.io/
        address contractAddress_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address contractAddress_USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        address contractAddress_DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

        IERC20 USDC_Token = IERC20(contractAddress_USDC);
        USDC_Token.transferFrom(msg.sender, address(this), amount);

        IERC20 USDT_Token = IERC20(contractAddress_USDT);
        USDT_Token.transferFrom(msg.sender, address(this), amount);

        IERC20 DAI_Token = IERC20(contractAddress_DAI);
        DAI_Token.transferFrom(msg.sender, address(this), amount);
    }
}