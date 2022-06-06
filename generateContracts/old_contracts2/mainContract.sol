// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./merchantContract.sol";
import "hardhat/console.sol";

contract MainContract {
    /* ========== SYSTEM ========== */
    address private owner_address;

    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }



    /* ========== MERCHANTs ========== */
    struct Merchant {
        uint id;
        address merchantContract_address;   // buyers will be sending the money to this address
        address merchant_address;           // and then the money will be sent to this address
        string name;
        // uint256 escrow_amount;              // amount waiting for escrow_time to end to be added to balance
        // uint256 balance;                    // amount verified and ready to sendToMerchant
    }

    uint public merchantsCounter; // count the nº of merchants
    mapping (uint => MerchantContract) public MerchantContracts;
    mapping(uint => Merchant) public merchants;



    /* ========== CONSTRUCTOR ========== */
    constructor() {
        owner_address = msg.sender;
        merchantsCounter = 0;
    }



    /* ========== MERCHANT_CONTRACTs ========== */
    function getMerchantAddress(uint MerchantID) public view onlyOwner {
        console.log("Merchant Address: ", MerchantContracts[MerchantID].getMerchantAddress(), "!!");
    }

    function addMerchantContract(address MerchantAddress, string memory MerchantName) public onlyOwner {
        MerchantContracts[merchantsCounter] = new MerchantContract(owner_address, MerchantAddress, MerchantName);
        merchants[merchantsCounter] = Merchant(merchantsCounter, address(MerchantContracts[merchantsCounter]), MerchantAddress, MerchantName);

        console.log("Created new Merchant!");
        console.log("MerchantContract Address: ", address(MerchantContracts[merchantsCounter]));
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);

        emit CreateMerchantContract(merchantsCounter, address(MerchantContracts[merchantsCounter]), MerchantAddress, MerchantName);
        merchantsCounter++;
    }

    function complete(uint MerchantID, uint PurchaseID) public onlyOwner {
        MerchantContracts[MerchantID].complete(PurchaseID);
        console.log("Purchase of MerchantID ", MerchantID);
        console.log(" w/ PurchadeID ", PurchaseID, " completed!!");
    }

    function sendToMerchant(uint MerchantID) public onlyOwner {
        MerchantContracts[MerchantID].sendToMerchant();
        console.log("Balance sent to MerchantID ", MerchantID, "!!");
    }

    function changeEscrowTime(uint MerchantID, uint NewEscrowTime) public onlyOwner {
        MerchantContracts[MerchantID].changeEscrowTime(NewEscrowTime);
        console.log("EscrowTime of MerchantID ", MerchantID);
        console.log(" changed to ", NewEscrowTime, "!!");
    }



    /* ========== EVENTS ========== */
    event CreateMerchantContract(uint ID, address MerchantContractAddress, address MerchantAddress, string MerchantName);
}