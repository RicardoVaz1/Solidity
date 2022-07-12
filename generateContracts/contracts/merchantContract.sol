// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./mainContract.sol";

contract MerchantContract is Ownable {
    /* ========== SYSTEM ========== */
    MainContract mainContract;

    bool public approved; // true = approved; false = not approved
    bool public paused; // true = withdrawals paused; false = withdrawals unpaused

    modifier approvedMerchant() {
        require(approved == true, "Merchant not approved!");
        _;
    }

    modifier pausedWithdrawals() {
        require(paused == false, "Withdrawals are paused!");
        _;
    }



    /* ========== MERCHANT ========== */
    address payable private merchant_address;   // buyers will be sending the money to merchantContract_address and then the money will be sent to this address
    string public name;
    uint256 private total_escrow_amount;        // total amount in escrow
    uint256 private balance;                    // amount verified and ready to withdrawal

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }



    /* ========== PURCHASEs ========== */
    struct Purchase {
        uint256 dateF;
        uint256 amount;
        uint status; // 0: default, purchase wasn't created; 1: purchase created, but not paid; 2: purchase created and paid; 3: purchase refunded
        uint256 escrow_amount; // amount waiting for escrow_time to end to be added to balance
        uint escrow_time; // time the merchant has to wait, for the money to be sent to his wallet
    }

    // idPurchase => Purchase
    mapping(uint => Purchase) public purchases;



    /* ========== HISTORICs ========== */
    struct MerchantHistoric {
        uint Sells;
        uint Refunds;
    }

    // merchant_address => MerchantHistoric
    mapping(address => MerchantHistoric) private merchantHistoric;


    struct BuyersHistoric {
        uint Purchases;
        uint Cancellations;
    }

    // msg.sender => BuyersHistoric
    mapping(address => BuyersHistoric) private buyersHistoric;



    /* ========== CONSTRUCTOR ========== */
    constructor(address payable MerchantAddress, string memory MerchantName) {
        merchant_address = MerchantAddress;
        name = MerchantName;
        total_escrow_amount = 0;
        balance = 0;
        
        approved = false;
    }



    /* ========== SYSTEM ========== */
    function getMerchantAddress() public view onlyOwner returns(address) {
        console.log("Merchant Address: ", merchant_address);
        return merchant_address;
    }

    function approveMerchant() public onlyOwner {
        approved = true;
        console.log("Merchant ", merchant_address, " is approved!");
        emit ApprovedMerchant(address(this), approved);
    }

    function disapproveMerchant() public onlyOwner {
        approved = false;
        console.log("Merchant ", merchant_address, " is disapproved!");
        emit ApprovedMerchant(address(this), approved);
    }

    function pauseWithdrawals() public onlyOwner {
        paused = true;
        console.log(merchant_address, " --> Merchant withdrawals are paused!");
        emit PausedWithdrawals(address(this), paused);
    }

    function unpauseWithdrawals() public onlyOwner {
        paused = false;
        console.log(merchant_address, " --> Merchant withdrawals are unpaused!");
        emit PausedWithdrawals(address(this), paused);
    }



    /* ========== MERCHANTs ========== */
    function checkMyAddress() public view onlyMerchant approvedMerchant returns(address) {
        console.log("My address is: ", merchant_address);
        return merchant_address;
    }

    function changeMyAddress(address payable NewAddress) public onlyMerchant approvedMerchant {
        merchant_address = NewAddress;
        console.log("My new address is: ", merchant_address);
        // emit ChangedMyAddress(merchant_address);
    }

    function checkMyEscrowAmount() public view onlyMerchant approvedMerchant returns(uint256) {
        console.log("My EscrowAmount: ", total_escrow_amount);
        return total_escrow_amount;
    }

    function checkMyBalance() public view onlyMerchant approvedMerchant returns(uint256) {
        console.log("My Balance: ", balance);
        return balance;
    }

    function createPurchase(uint idPurchase, uint256 purchaseAmount, uint escrowTime) public onlyMerchant approvedMerchant {
        // Purchase { uint256 dateF, uint256 amount, uint status, uint256 escrow_amount, uint escrow_time }
        purchases[idPurchase] = Purchase(block.timestamp, purchaseAmount, 1, 0, escrowTime);

        console.log("Puchase w/ id ", idPurchase);
        console.log(" and amount ", purchaseAmount, " was created!");

        // Date | Amount | EscrowTime 
        emit CreatePurchase(block.timestamp, purchaseAmount, escrowTime);
    }

    function complete(uint idPurchase) public onlyMerchant approvedMerchant {
        require(purchases[idPurchase].dateF < block.timestamp, "The escrow time of this purchase isn't over yet!");

        total_escrow_amount -= purchases[idPurchase].amount;

        purchases[idPurchase].escrow_amount -= purchases[idPurchase].amount;
        balance += purchases[idPurchase].amount;

        console.log("Puchase w/ id ", idPurchase, " was completed!");
        console.log("TotalEscrowAmount: ", total_escrow_amount);
        console.log("Balance: ", balance);

        emit Complete(idPurchase);
    }

    function withdrawal() public onlyMerchant pausedWithdrawals approvedMerchant {
        require(balance > 0, "Balance should be greater than 0!!");

        merchant_address.transfer(balance);

        console.log("Address: ", merchant_address);
        console.log("Balance Sent: ", balance);

        // From | Amount
        emit Withdrawal(address(this), balance);
        balance = 0;
    }

    /*function withdrawalToThisAddress(address payable ThisAddress) public onlyMerchant pausedWithdrawals approvedMerchant {
        require(balance > 0, "Balance should be greater than 0!!");

        ThisAddress.transfer(balance);

        console.log("Address: ", ThisAddress);
        console.log("Balance Sent: ", balance);

        // From | Amount
        emit Withdrawal(address(this), balance);
        balance = 0;
    }*/

    function refund(uint idPurchase, address payable BuyerAddress, uint256 refundAmount) public onlyMerchant pausedWithdrawals approvedMerchant {
        require(refundAmount > 0, "Refund amount should be greater than 0!!");
        require(refundAmount <= purchases[idPurchase].amount, "Refund amount shouldn't be greater than the purchaseAmount!");

        if(purchases[idPurchase].status == 0) revert("The purchase doesn't exist!"); // By default status is 0
        if(purchases[idPurchase].status == 1) revert("That purchase hasn't yet been paid!");
        // if(purchases[idPurchase].status == 2) revert("That purchase has already been paid!");
        if(purchases[idPurchase].status == 3) revert("That purchase has already been refunded!");

        // if(address(this).balance < refundAmount) revert("You don't have enough money in the smart-contract!");
        if(total_escrow_amount+balance < refundAmount) revert("You don't have enough money in the smart-contract!");

        if(purchases[idPurchase].escrow_amount >= refundAmount) {
            purchases[idPurchase].escrow_amount -= refundAmount;
            total_escrow_amount -= refundAmount;
            console.log("EscrowAmount updated!");
        }
        else if(balance >= refundAmount) {
            balance -= refundAmount;
            console.log("Balance updated!");
        }
        else revert("Error processing refund, check your smart-contract balance!");

        BuyerAddress.transfer(refundAmount);

        purchases[idPurchase].status = 3; // Purchase refunded

        historic(BuyerAddress, 1);

        console.log("idPurchase: ", idPurchase);
        console.log("Address: ", BuyerAddress);
        console.log("RefundAmount: ", refundAmount);

        // From | To | Amount
        emit Refund(address(this), BuyerAddress, refundAmount);
    }

    function topUpMyContract() external payable onlyMerchant approvedMerchant {
        if(msg.value == 0) revert("Amount should be greater than 0!");

        balance += msg.value;
        console.log("Balance: ", balance);

        // To | Amount
        emit TopUpMyContract(address(this), msg.value);
    }



    /* ========== BUYERs ========== */
    function buy(uint idPurchase) external payable approvedMerchant {
        if(msg.value == 0) revert("Amount should be greater than 0!");

        if(purchases[idPurchase].status == 0) revert("The purchase doesn't exist!"); // By default status is 0
        // if(purchases[idPurchase].status == 1) revert("The purchase hasn't yet been paid!");
        if(purchases[idPurchase].status == 2) revert("The purchase has already been paid!");
        if(purchases[idPurchase].status == 3) revert("The purchase has already been refunded!");
        if(msg.value != purchases[idPurchase].amount) revert("Wrong amount!");

        total_escrow_amount += msg.value;
        console.log("TotalEscrowAmount: ", total_escrow_amount);

        // Purchase { uint256 dateF, uint256 amount, uint status, uint256 escrow_amount, uint escrow_time }
        purchases[idPurchase].dateF = block.timestamp + purchases[idPurchase].escrow_time;
        purchases[idPurchase].status = 2;
        purchases[idPurchase].escrow_amount = msg.value;

        historic(msg.sender, 0);

        // ID | DateF | From | To | Amount
        emit Buy(idPurchase, purchases[idPurchase].dateF, msg.sender, address(this), msg.value);
    }

    /* ========== HISTORICs ========== */
    function historic(address BuyerAddress, uint purchaseStatus) private {
        // struct MerchantHistoric { uint Sells; uint Refunds; }
        // struct BuyersHistoric { uint Purchases; uint Cancellations; }

        // MainContract mainContract;

        if(purchaseStatus == 0) {
            // purchase completed
            merchantHistoric[merchant_address].Sells += 1;
            buyersHistoric[BuyerAddress].Purchases += 1;

            // console.log("Msg.sender 1 is: ", msg.sender);
            // console.log("MerchantContract address: ", address(this));

            mainContract.saveHistoric(merchant_address, BuyerAddress, 0);
        }
        else {
            // purchase refunded
            merchantHistoric[merchant_address].Refunds += 1;
            buyersHistoric[BuyerAddress].Cancellations += 1;

            // console.log("Msg.sender 3 is: ", msg.sender);
            // console.log("MerchantContract address: ", address(this));

            mainContract.saveHistoric(merchant_address, BuyerAddress, 1);
        }

        // MerchantContractAddress | MerchantSells | MerchantRefunds
        emit Historic(address(this), merchantHistoric[merchant_address].Sells, merchantHistoric[merchant_address].Refunds);
    }



    /* ========== EVENTS ========== */
    event PausedWithdrawals(address MerchantContractAddress, bool PausedWithdrawals); // true = withdrawals paused; false = withdrawals unpaused
    event ApprovedMerchant(address MerchantContractAddress, bool ApprovedMerchant); // true = approved; false = not approved
    // event ChangedMyAddress(NewAddress);
    event CreatePurchase(uint256 Date, uint256 Amount, uint EscrowTime);
    event TopUpMyContract(address MerchantContractAddress, uint256 Amount);
    event Historic(address MerchantContractAddress, uint Sells, uint Refunds);

    // Purchase Flow
    event Buy(uint PurchaseID, uint256 DateF, address BuyerAddress, address MerchantContractAddress, uint256 Amount);
    event Complete(uint PurchaseID);
    event Withdrawal(address MerchantContractAddress, uint256 Amount);
    event Refund(address MerchantContractAddress, address BuyerAddress, uint256 Amount);
}