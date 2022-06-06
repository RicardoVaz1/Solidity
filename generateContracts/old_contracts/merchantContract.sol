// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

// import "./Libraries.sol";
import "hardhat/console.sol";

contract MerchantContract {
    // using Address for address payable;
    
    /* ========== SYSTEM ========== */
    address private owner_address;
    bool public paused; // true = paused; false = unpaused

    modifier systemState() {
        require(paused == false, "The system is paused!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }


    /* ========== MERCHANT ========== */
    struct Merchant {
        uint id;
        address _address;
        string name;
        uint256 escrow_amount; // amount waiting for escrow_time to end to be added to balance
        uint256 balance; // amount verified and ready to sendToMerchant
    }

    uint public merchantsCount; // count the nº of merchants
    mapping(uint => Merchant) public merchants;

    uint private merchant_id;
    address public merchant_address;

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
    }

    uint public purchasesCount; // count the nº of purchases
    mapping(uint => Purchase) public purchases;
    uint public escrow_time; // time the merchant has to wait, for the money to be sent to his wallet



    /* ========== CONSTRUCTOR ========== */
    constructor(address OwnerAddress, address MerchantAddress, string memory MerchantName) {
        owner_address = OwnerAddress;

        merchantsCount++;
        merchants[merchantsCount] = Merchant(merchantsCount, MerchantAddress, MerchantName, 0, 0);
        merchant_id = merchantsCount;
        merchant_address = MerchantAddress;
        emit CreateMerchant(merchantsCount, MerchantAddress);
        
        paused = false;
        buyersCount = 0;
        purchasesCount = 0;
        escrow_time = 259200; // default: 3 days = 259200 seconds
    }


    /* ========== SYSTEM ========== */
    function getMerchantAddress() public view /*onlyOwner*/ returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }

    function getMerchantAddress2(uint MerchantID) public view onlyOwner returns(address) {
        console.log("Merchant Address: ", merchants[MerchantID]._address);
        return merchants[MerchantID]._address;
    }

    /*function verifyMerchantAddress(address MerchantAddress) public view returns(bool) {
        for(uint i = 0; i <= merchantsCount; i++) {
            if(MerchantAddress == merchants[i]._address) {
                console.log("This address already exists in the system!");
                return true;
            }
        }
        console.log("This address doens't exists in the system!");
        return false;
    }*/

    function pauseMerchant() public /*onlyOwner*/ {
        paused = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function unpauseMerchant() public /*onlyOwner*/ {
        paused = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function deleteMerchant() public /*onlyOwner*/ {
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(merchant_address);
        delete merchants[merchant_id]._address;
        delete merchant_address;
    }

    function changeEscrowTime(uint NewEscrowTime) public onlyOwner {
        emit ChangedEscrowTime(NewEscrowTime);
        escrow_time = NewEscrowTime;
        console.log("New escrow time is: ", escrow_time);
    }

    function complete(uint PurchaseID, uint MerchantID) public onlyOwner {
        merchants[MerchantID].escrow_amount -= purchases[PurchaseID].amount;
        merchants[MerchantID].balance += purchases[PurchaseID].amount;

        console.log("Purchase w/ the id ", purchases[PurchaseID].id, " was added to Merchant balance!");
        emit Complete(PurchaseID, MerchantID, merchants[MerchantID].escrow_amount, merchants[MerchantID].balance);
    }

    function sendToMerchant(uint MerchantID) public payable onlyOwner {
        require(merchants[MerchantID].balance > 0, "Merchant Balance should be >0!!");

        payable(merchants[MerchantID]._address).transfer(merchants[MerchantID].balance);
        // payable(merchants[MerchantID]._address).transfer(msg.value);

        console.log("Address: ", merchants[MerchantID]._address);
        console.log("Balance Sent: ", merchants[MerchantID].balance);

        merchants[MerchantID].balance = 0;
        // console.log("Amount: ", merchants[MerchantID].balance);
        emit SendToMerchant(MerchantID, merchants[MerchantID]._address, merchants[MerchantID].balance);
    }



    /* ========== MERCHANTs ========== */
    function changeMerchantAddress(address NewMerchantAddress) public virtual onlyMerchant systemState {
        emit ChangedMerchantAddress(merchant_address, NewMerchantAddress);
        merchant_address = NewMerchantAddress;
        merchants[merchant_id]._address = NewMerchantAddress;
        console.log("New Merchant address is: ", merchant_address);
    }

    function refund(address BuyerAddress, uint256 Amount) public payable onlyMerchant systemState {
        require(Amount > 0, "Amount should be >0!!");

        uint MerchantID = getMerchantID(msg.sender);
        // console.log("EscrowAmount: ", merchants[MerchantID].escrow_amount);
        merchants[MerchantID].escrow_amount -= Amount;
        console.log("EscrowAmount: ", merchants[MerchantID].escrow_amount);

        updatePurchasesCount(BuyerAddress);

        payable(BuyerAddress).transfer(Amount);
        // payable(BuyerAddress).transfer(msg.value);
        console.log("Address: ", BuyerAddress);
        console.log("Address: ", Amount);

        // From | To | Amount
        emit Refund(merchant_address, BuyerAddress, Amount);
    }

    function updatePurchasesCount(address BuyerAddress) private {
        uint BuyerID = getBuyerID(BuyerAddress);
        // console.log("Buyers Purchases: ", buyers[BuyerID].purchasesCountBuyer);
        buyers[BuyerID].purchasesCountBuyer--;
        console.log("Buyers Purchases: ", buyers[BuyerID].purchasesCountBuyer);
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

    function getMerchantID(address MerchantAddress) private view returns(uint) {
        uint id;
        for(uint i = 0; i <= merchantsCount; i++) {
            if(MerchantAddress == merchants[i]._address) {
                id = i;
            }
        }
        return id;
    }

    function getBuyerID(address BuyerAddress) private view returns(uint) {
        uint id;
        for(uint i = 0; i <= buyersCount; i++) {
            if(BuyerAddress == buyers[i]._address) {
                id = i;
            }
        }
        return id;
    }

    function buy(address BuyerAddress, uint Amount, address MerchantAddress) public systemState {
        //require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(Amount > 0, "Amount should be >0!");

        createBuyer(BuyerAddress);
        // createPurchase(Amount);

        uint256 dateI = block.timestamp;
        uint256 dateF = dateI + escrow_time;

        // merchants[merchant_id].escrow_amount += Amount;
        uint MerchantID = getMerchantID(MerchantAddress);
        merchants[MerchantID].escrow_amount += Amount;

        console.log("MerchantID: ", MerchantID);
        console.log("EscrowAmount: ", merchants[MerchantID].escrow_amount);
        
        purchasesCount++;
        purchases[purchasesCount] = Purchase(purchasesCount, dateI, dateF, Amount);

        uint BuyerID = getBuyerID(BuyerAddress);
        buyers[BuyerID].purchasesCountBuyer++;

        // ID | DateI | DateF | From | To | Amount
        emit Buy(purchasesCount, dateI, dateF, BuyerAddress, merchant_address, Amount);
    }



    /* ========== EVENTS ========== */
    event PausedMerchant(address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event DeletedMerchant(address MerchantAddress);
    event ChangedMerchantAddress(address MerchantAddress, address NewMerchantAddress);
    event ChangedEscrowTime(uint NewEscrowTime);

    event CreateMerchant(uint MerchantID, address MerchantAddress);
    event CreateBuyer(uint BuyerID, address BuyerAddress);
    
    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateI, uint256 DateF, address BuyerAddress, address MerchantAddress, uint256 Amount);
    event Complete(uint PurchaseID, uint MerchantID, uint256 EscrowAmount, uint256 Balance);
    event SendToMerchant(uint MerchantID, address MerchantAddress, uint256 Amount);
    event Refund(address MerchantAddress, address BuyerAddress, uint256 Amount);
}
