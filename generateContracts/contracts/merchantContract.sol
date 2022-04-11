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

    event PausedMerchant(uint256 Date, address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event DeletedMerchant(uint256 Date, address MerchantAddress);

    modifier systemState() {
        require(paused == false, "The system is Paused!");
        _;
    }
    /* ------------------ */


    /* ----- MERCHANT ----- */
    address public merchant_address;
    uint256 public merchant_balance;
    string public merchant_name;
    
    event ChangedMerchantAddress(uint256 Date, address MerchantAddress, address NewMerchantAddress);
    event Refund(uint256 Date, uint ID, string TransactionType, address MerchantAddress, address BuyerAddress, uint256 Amount, string Status); // Date | ID | TransactionType | From | To | Value | Status


    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }
    /* -------------------- */



    /* ----- BUYERs ----- */
    //address public buyer_address;
    //uint256 public amount;

    mapping (uint => address) buyersAddresses;
    mapping (address => uint256) buyersAmounts;

    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }
    State private currsState;

    mapping (address => State) buyersStates;
    uint256 buyersCounter;

    using Counters for Counters.Counter;
    Counters.Counter private PurchaseID;
    
    uint256 newPurchaseID;
    
    
    // Date | ID | TransactionType | From | To | Value | Status
    event Deposited(uint256 Date, uint ID, string TransactionType, address BuyerAddress, address MerchantAddress, uint256 Amount, string Status);
    event Sell(uint256 Date, uint ID, string TransactionType, address BuyerAddress, address MerchantAddress, uint256 Amount, string Status);
    /* ------------------ */



    // FUNCTIONS
    constructor(address OwnerAddress, address MerchantAddress, string memory MerchantName, bool MerchantState) {
        owner_address = OwnerAddress;
        merchant_address = MerchantAddress;
        merchant_name = MerchantName;

        paused = MerchantState;

        buyersCounter = 0;
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
        
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(block.timestamp, merchant_address);
        delete merchant_address;
    }
    /* ------------------ */




    /* ----- MERCHANT ----- */
    function changeMerchantAddress(address NewMerchantAddress) public virtual onlyMerchant systemState {
        emit ChangedMerchantAddress(block.timestamp, merchant_address, NewMerchantAddress);
        merchant_address = NewMerchantAddress;
        console.log("New Merchant address is: ", merchant_address);
    }

    // REFUNDS
    function refund(address BuyerAddress, uint256 ID) public payable onlyMerchant systemState {
        require(msg.value * (1 ether) > 0, "Refund amount should be >0!");

        // buyer_address = BuyerAddress;
        // amount = msg.value;

        payable(BuyerAddress).transfer(msg.value);

        // Date | ID | TransactionType | From | To | Value | Status
        emit Refund(block.timestamp, ID, "Refund", merchant_address, BuyerAddress, msg.value, "Complete");

        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", ID);
        console.log("Transaction Type: ", "Refund");
        console.log("From: ", merchant_address, "(Merchant)");
        console.log("To: ", BuyerAddress, "(Buyer)");
        console.log("Value: ", msg.value);
        console.log("Status: ", "Complete");
    }
    /* -------------------- */



    /* ----- BUYERs ----- */
    // ESCROW
    function deposit() public payable systemState {
        require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        //require(buyersStates[msg.sender] == State.AWAITING_PAYMENT, "Already paid!");
        require(msg.value * (1 ether) > 0, "Deposit amount should be >0!");

        //buyer_address = msg.sender;
        //amount = msg.value;


        for(uint i = 0; i < buyersCounter; i++) {
            if(BuyerAddress == buyersAddresses[i]) {
                console.log("This Address already exists in the system!");
                return;
            }
        }

        buyersAddresses[buyersCounter] = msg.sender;
        buyersCounter += 1;

        buyersAmounts[msg.sender] = msg.value;
        
        PurchaseID.increment();
        newPurchaseID = PurchaseID.current();


        // Date | TransactionType | From | To | Value | Status
        emit Deposited(block.timestamp, newPurchaseID, "Deposit", msg.sender, merchant_address, msg.value, "Complete");
        
        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", newPurchaseID);
        console.log("Transaction Type: ", "Deposit");
        console.log("From: ", msg.sender, "(Buyer)");
        console.log("To: ", merchant_address, "(Merchant)");
        console.log("Value: ", msg.value);
        console.log("Status: ", "Complete");


        // Waiting x blocks before send the money to Merchant
        /* ... */

        //currsState = State.WAIT_A_MOMENT;
        buyersStates[msg.sender] = State.WAIT_A_MOMENT;

        //transactionSucess(msg.sender, msg.value, newPurchaseID);
    }

    function transactionSucess(address BuyerAddress, uint256 Amount, uint256 ID) private systemState {
        require(buyersStates[BuyerAddress] == State.WAIT_A_MOMENT, "Need to make the deposit first!");
        
        // buyer_address = BuyerAddress;
        // amount = Amount;

        payable(merchant_address).transfer(Amount);
        buyersStates[BuyerAddress] = State.COMPLETE;

        // Date | ID | TransactionType | From | To | Value | Status
        emit Sell(block.timestamp, ID, "Sell", BuyerAddress, merchant_address, Amount, "Complete");
        
        console.log("Time: ", block.timestamp);
        console.log("Purchase ID: ", ID);
        console.log("Transaction Type: ", "Sell");
        console.log("From: ", BuyerAddress, "(Buyer)");
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