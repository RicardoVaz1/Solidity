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
        // bool complete; // true = completed; false = incompleted
    }

    uint public purchasesCount; // count the nº of purchases
    mapping(uint => Purchase) public purchases;
    // uint public cancel_time;
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
        // cancel_time = 259200; // default: 3 days = 259200 seconds
        escrow_time = 259200; // default: 3 days = 259200 seconds
    }


    /* ========== SYSTEM ========== */
    function getMerchantAddress() public view onlyOwner returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }

    function getMerchantAddress2(uint MerchantID) public view onlyOwner returns(address) {
        console.log("Merchant Address: ", merchants[MerchantID]._address);
        return merchants[MerchantID]._address;
    }

    function pauseMerchant() public onlyOwner {
        paused = true;
        console.log("Merchant ", merchant_address, " is paused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function unpauseMerchant() public onlyOwner {
        paused = false;
        console.log("Merchant ", merchant_address, " is unpaused!");
        emit PausedMerchant(merchant_address, paused);
    }

    function deleteMerchant() public onlyOwner {
        console.log("Merchant ", merchant_address, " was deleted!");
        emit DeletedMerchant(merchant_address);
        delete merchants[merchant_id]._address;
        delete merchant_address;
    }

    function changeEscrowTime(uint NewEscrowTime) public onlyOwner {
        emit ChangedEscrowTime(NewEscrowTime);
        escrow_time = NewEscrowTime;
        console.log("New cancel time is: ", escrow_time);
    }

    function complete(uint PurchaseID, uint MerchantID) public onlyOwner {
        uint256 EscrowAmount = merchants[MerchantID].escrow_amount;
        uint256 Balance = merchants[MerchantID].balance;

        EscrowAmount -= purchases[PurchaseID].amount;
        Balance += purchases[PurchaseID].amount;

        console.log("Purchase w/ the id ", purchases[PurchaseID].id, " was added to Merchant balance!");
        emit Complete(PurchaseID, MerchantID, EscrowAmount, Balance);
    }

    function sendToMerchant(uint MerchantID) public payable onlyOwner {
        address MerchantAddress = merchants[MerchantID]._address;
        uint256 Amount = merchants[MerchantID].balance;

        payable(MerchantAddress).transfer(Amount);

        // console.log("Sent ", Amount, " ETH to ", MerchantAddress, " !");
        emit SendToMerchant(MerchantID, MerchantAddress, Amount);
    }



    /* ========== MERCHANTs ========== */
    function changeMerchantAddress(address NewMerchantAddress) public virtual onlyMerchant systemState {
        emit ChangedMerchantAddress(merchant_address, NewMerchantAddress);
        merchant_address = NewMerchantAddress;
        merchants[merchant_id]._address = NewMerchantAddress;
        console.log("New Merchant address is: ", merchant_address);
    }

    /*function changeCancelTime(uint NewCancelTime) public onlyMerchant systemState {
        emit ChangedCancelTime(merchant_address, NewCancelTime);
        cancel_time = NewCancelTime;
        console.log("New cancel time is: ", cancel_time);
    }*/

    function refund(address BuyerAddress, uint256 Amount) public payable onlyMerchant systemState {
        require(Amount > 0, "Amount should be >0!!");

        uint BuyerID = getBuyerID(BuyerAddress);
        buyers[BuyerID].purchasesCountBuyer--;

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
    }

    function getMerchantID() private {
        for(uint i = 0; i < merchantsCount; i++) {
            if(merchant_address == merchants[i]._address) {
                return i;
            }
        }
    }*/

    function getBuyerID(address BuyerAddress) private view returns(uint) {
        uint id;
        for(uint i = 0; i < buyersCount; i++) {
            if(BuyerAddress == buyers[i]._address) {
                id = i;
            }
        }
        return id;
    }

    function buy(address BuyerAddress, uint256 Amount) public payable systemState {
        //require(msg.sender != merchant_address, "Only Buyer can call this funcion");
        require(Amount > 0, "Amount should be >0!");

        createBuyer(BuyerAddress);
        // createPurchase(Amount);

        uint256 dateI = block.timestamp;
        uint256 dateF = dateI + escrow_time;

        // uint MerchantID = getMerchantID();
        uint256 EscrowAmount = merchants[merchant_id].escrow_amount;

        uint BuyerID = getBuyerID(BuyerAddress);

        purchasesCount++;
        purchases[purchasesCount] = Purchase(purchasesCount, dateI, dateF, Amount);

        EscrowAmount += Amount;

        buyers[BuyerID].purchasesCountBuyer++;

        // ID | DateI | DateF | From | To | Amount
        emit Buy(purchasesCount, dateI, dateF, BuyerAddress, merchant_address, Amount);
    }

    /*function cancel(uint PurchaseID, uint BuyerID) public payable systemState {
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
    }*/



    /* ========== EVENTS ========== */
    event PausedMerchant(address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event DeletedMerchant(address MerchantAddress);
    event ChangedMerchantAddress(address MerchantAddress, address NewMerchantAddress);
    // event ChangedCancelTime(address MerchantAddress, uint NewCancelTime);
    event ChangedEscrowTime(uint NewEscrowTime);

    event CreateMerchant(uint MerchantID, address MerchantAddress);
    event CreateBuyer(uint BuyerID, address BuyerAddress);
    // event CreatePurchase(uint PurchaseID, uint256 DateI, uint256 DateF, uint256 Amount, bool Complete);
    
    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateI, uint256 DateF, address BuyerAddress, address MerchantAddress, uint256 Amount);
    // event Cancel(uint PurchaseID, uint BuyerID, uint256 Amount);
    event Complete(uint PurchaseID, uint MerchantID, uint256 EscrowAmount, uint256 Balance);
    event SendToMerchant(uint MerchantID, address MerchantAddress, uint256 Amount);
    event Refund(address MerchantAddress, address BuyerAddress, uint256 Amount);
}