// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

contract MerchantContract {
    /* ========== SYSTEM ========== */
    address private owner_address;
    bool public paused; // true = paused; false = unpaused

    modifier systemState() {
        require(paused == false, "The system is paused!");
        _;
    }


    /* ========== MERCHANT ========== */
    struct Merchant {
        uint id;
        address _address;
        string name;
        uint256 balance; // amount verified and ready to sendToMerchant()
    }

    uint public merchantsCount; // count the nº of merchants
    mapping(uint => Merchant) public merchants;
    // mapping(address => Merchant) public merchants;

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }


    /* ========== BUYERs ========== */
    struct Buyer {
        uint id;
        address _address;
        uint purchasesCountBuyer; // count the nº of purchases of each buyer
    }

    uint public buyersCount; // count the nº of buyers
    mapping(uint => Buyer) public buyers;


    /* ========== PURCHASEs ========== */
    struct Purchase {
        uint id;
        uint256 dateI;
        uint256 dateF;
        uint256 amount;
        bool complete; // true = completed; false = incompleted
    }

    uint public purchasesCount; // count the nº of purchases
    mapping(uint => Purchase) public purchases;
    uint public cancel_time; // 3 days = 259200 seconds



    /* ========== CONSTRUCTOR ========== */
    constructor(address OwnerAddress, address MerchantAddress, string memory MerchantName, bool MerchantState) {
        owner_address = OwnerAddress;

        merchantsCount++;
        merchants[merchantsCount] = Merchant(merchantsCount, MerchantAddress, MerchantName, 0);
        // merchants[MerchantAddress] = Merchant(MerchantAddress, MerchantName, 0);
        emit CreateMerchant(merchantsCount, MerchantAddress);
        
        paused = MerchantState;
        buyersCount = 0;
        purchasesCount = 0;
        cancel_time = 259200; // 3 days = 259200 seconds
    }


    /* ========== SYSTEM ========== */
    function pauseMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");

        paused = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function unpauseMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");
        
        paused = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function deleteMerchant(address Address) public {
        require(Address == owner_address, "Only Owner can call this function");
        
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(merchant_address);
        delete merchant_address;
    }

    function complete(address Address, uint PurchaseID, uint MerchantID, uint BuyerID) {
        require(Address == owner_address, "Only Owner can call this function");
        // require(purchases[PurchaseID].dateF > block.timestamp, "The cancellation time for this purchase isn't over yet!");

        // address MerchantAddress = merchants[MerchantID]._address;
        uint256 Amount = merchants[MerchantID].balance;

        for(uint i = 0; i < purchasesCount; i++) {
            if(PurchaseID == purchases[i].id) {
                purchases[i].complete = true;
                Amount += purchases[i].amount;
                buyers[BuyerID].purchasesCountBuyer++;

                console.log("Purchase w/ the id ", purchases[i].id, " is completed!");
                emit Complete(PurchaseID, MerchantID, Amount);
            }
        }
    }

    function sendToMerchant(address Address, uint MerchantID) public payable {
        require(Address == owner_address, "Only Owner can call this function");
        
        address MerchantAddress = merchants[MerchantID]._address;
        uint256 Amount = merchants[MerchantID].balance;

        payable(MerchantAddress).transfer(Amount);

        console.log("Sent ", Amount, " ETH to ", MerchantAddress, " !");
        emit SendToMerchant(MerchantID, MerchantAddress, Amount);
    }



    /* ========== MERCHANTs ========== */
    function changeMerchantAddress(address NewMerchantAddress) public virtual onlyMerchant systemState {
        emit ChangedMerchantAddress(merchant_address, NewMerchantAddress);
        merchant_address = NewMerchantAddress;
        console.log("New Merchant address is: ", merchant_address);
    }

    function refund(address BuyerAddress, uint256 Amount) public payable onlyMerchant systemState {
        require(Amount > 0, "Amount should be >0!!");

        payable(BuyerAddress).transfer(Amount);

        // From | To | Amount
        emit Refund(merchant_address, BuyerAddress, Amount);
    }


    /* ========== BUYERs ========== */
    function createBuyer(address BuyerAddress) private {
        for(uint i = 0; i < buyersCount; i++) {
            if(BuyerAddress == buyers[i]._address) {
                console.log("This address already exists in the system!");
                return;
            }
        }

        buyersCount++;
        buyers[buyersCount] = Buyer(buyersCount, BuyerAddress, 0);

        // ID | BuyerAddress
        emit CreateBuyer(buyersCount, BuyerAddress);
    }

    /*function createPurchase(uint256 Amount) private {
        uint256 dateI = block.timestamp;
        uint256 dateF = dateI + cancel_time;

        purchasesCount ++;
        purchases[purchasesCount] = Purchase(purchasesCount, dateI, dateF, Amount, false);

        emit CreatePurchase(purchasesCount, dateI, dateF, Amount, false);
    }*/

    function buy(address BuyerAddress, uint256 Amount) public payable systemState {
        //require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(Amount > 0, "Amount should be >0!");

        createBuyer(BuyerAddress);
        // createPurchase(Amount);

        uint256 dateI = block.timestamp;
        uint256 dateF = dateI + cancel_time;

        purchasesCount++;
        purchases[purchasesCount] = Purchase(purchasesCount, dateI, dateF, Amount, false);
        
        // ID | DateI | DateF | From | To | Amount
        emit Buy(purchasesCount, dateI, dateF, BuyerAddress, merchant_address, Amount);
    }

    function cancel(uint PurchaseID, uint BuyerID) public payable systemState {
        //require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(purchases[PurchaseID].complete == false, "The cancellation time for this purchase is over!");

        address BuyerAddress = buyers[BuyerID]._address;
        uint256 Amount = purchases[PurchaseID].amount;

        for(uint i = 0; i < purchasesCount; i++) {
            if(PurchaseID == purchases[i].id) {
                purchases[i].complete = false;
                // Amount -= purchases[i].amount;
                payable(BuyerAddress).transfer(Amount);

                console.log("Purchase w/ the id ", purchases[i].id, " is canceled!");
                emit Cancel(PurchaseID, BuyerID, Amount);
            }
        }
    }



    /* ========== EVENTS ========== */
    event PausedMerchant(address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event DeletedMerchant(address MerchantAddress);
    event ChangedMerchantAddress(address MerchantAddress, address NewMerchantAddress);

    event CreateMerchant(uint MerchantID, address MerchantAddress);
    event CreateBuyer(uint BuyerID, address BuyerAddress);
    //event CreatePurchase(uint PurchaseID, uint256 DateI, uint256 DateF, uint256 Amount, bool Complete);
    
    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateI, uint256 DateF, address BuyerAddress, address MerchantAddress, uint256 Amount);
    event Cancel(uint PurchaseID, uint BuyerID, uint256 Amount);
    event Complete(uint PurchaseID, uint MerchantID, uint256 Amount);
    event SendToMerchant(uint MerchantID, address MerchantAddress, uint256 Amount);
    event Refund(address MerchantAddress, address BuyerAddress, uint256 Amount);
}