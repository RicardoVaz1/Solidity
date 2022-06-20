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

    struct MerchantHistoric {
        uint status; // 0: default, MerchantAddress doesn't exist; 1: MerchantAddress exist
        uint historic;
    }
    mapping(address => MerchantHistoric) public merchantsHistoric;
    
    struct BuyerHistoric {
        uint status; // 0: default, BuyerAddress doesn't exist; 1: BuyerAddress exist
        uint historic;
    }
    mapping(address => BuyerHistoric) public buyersHistoric;


    /* ========== MERCHANTs ========== */
    struct Merchant {
        MerchantContract merchantContract;   // buyers will be sending the money to this address
        string name;
    }

    uint merchantsCounter; // count the nº of merchants
    mapping(uint => Merchant) public merchants;


    struct NewMerchant {
        uint status; // 0: default, NewMerchant doesn't exist; 1: NewMerchant exist, but not approved; 2: NewMerchant exist and it's approved
        uint votes;
    }

    uint idNewMerchant;
    mapping(uint => NewMerchant) public merchantContractApproval;



    /* ========== CONSTRUCTOR ========== */
    /*constructor() {
        owner_address = msg.sender;
        merchantsCounter = 0;
    }*/

    constructor(address OWNER) {
        owner_address = OWNER;
        merchantsCounter = 0;
    }



    /* ========== MERCHANT_CONTRACTs ========== */
    function getMerchantAddress(uint MerchantID) public view onlyOwner returns(address) {
        address merchant_address = merchants[MerchantID].merchantContract.getMerchantAddress();
        console.log("Merchant Address: ", merchant_address, "!!");
        return merchant_address;
    }

    function addMerchantContract(address payable MerchantAddress, string memory MerchantName) public onlyOwner {
        MerchantContract merchantContract = new MerchantContract(MerchantAddress, MerchantName);
        merchants[merchantsCounter] = Merchant(merchantContract, MerchantName);

        console.log("Created new Merchant!");
        console.log("MerchantContract Address: ", address(merchantContract));
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);

        emit CreateMerchantContract(merchantsCounter, address(merchantContract), MerchantAddress, MerchantName);
        merchantsCounter++;
    }

    function freezeWithdrawalsMerchantContract(uint MerchantID) public onlyOwner {
        merchants[MerchantID].merchantContract.pauseMerchant();

        console.log("MerchantContract ", address(merchants[MerchantID].merchantContract), " Paused!");
        emit PausedMerchantContract(address(merchants[MerchantID].merchantContract), true);
    }

    function unfreezeWithdrawalsMerchantContract(uint MerchantID) public onlyOwner {
        merchants[MerchantID].merchantContract.unpauseMerchant();

        console.log("MerchantContract ", address(merchants[MerchantID].merchantContract), " Unpaused!");
        emit PausedMerchantContract(address(merchants[MerchantID].merchantContract), false);
    }

    function approveMerchant(address MerchantAddress) public onlyOwner {
        merchantsHistoric[MerchantAddress].status = 1;

        console.log("MerchantAddress ", MerchantAddress, " Approved!");
        emit ApproveMerchant(MerchantAddress);
    }

    function approveBuyer(address BuyerAddress) public onlyOwner {
        buyersHistoric[BuyerAddress].status = 1;

        console.log("BuyerAddress ", BuyerAddress, " Approved!");
        emit ApproveBuyer(BuyerAddress);
    }

    function historic(address MerchantAddress, address BuyerAddress, uint purchaseStatus) public {
        if(merchantsHistoric[MerchantAddress].status != 1) revert("Merchant not approved!");
        if(buyersHistoric[BuyerAddress].status != 1) revert("Buyer not approved!");

        if(purchaseStatus == 0) {
            // purchase completed
            merchantsHistoric[MerchantAddress].historic += 1;
            buyersHistoric[BuyerAddress].historic += 1;
        }
        else {
            // purchase refunded
            merchantsHistoric[MerchantAddress].historic -= 1;
            buyersHistoric[BuyerAddress].historic -= 1;
        }

        // Merchant | MerchantHistoric | Buyer | BuyerHistoric
        emit Historic(MerchantAddress, merchantsHistoric[MerchantAddress].historic, BuyerAddress, buyersHistoric[BuyerAddress].historic);
    }

    function voteNewMerchantContractApproval(uint MerchantContractID) public {
        if(merchantsHistoric[msg.sender].status != 1 && buyersHistoric[msg.sender].status != 1) revert("Address not approved!");

        merchantContractApproval[MerchantContractID].votes += 1;
        console.log("Merchant w/ id: ", MerchantContractID);
        console.log("Number of votes: ", merchantContractApproval[MerchantContractID].votes);

        // From | To
        emit VoteNewMerchantContractApproval(msg.sender, MerchantContractID);

        if(merchantContractApproval[MerchantContractID].votes > 100) {
            merchantContractApproval[MerchantContractID].status = 2;
            console.log("Merchant w/ id: ", MerchantContractID, " has been approved!");

            // NewMerchantContractApproved
            emit NewMerchantContractApproved(MerchantContractID);
        }
    }



    /* ========== EVENTS ========== */
    event CreateMerchantContract(uint ID, address MerchantContractAddress, address MerchantAddress, string MerchantName);
    event PausedMerchantContract(address MerchantContractAddress, bool SystemState); // true = paused; false = unpaused
    event ApproveMerchant(address MerchantAddress);
    event ApproveBuyer(address BuyerAddress);
    event Historic(address MerchantAddress, uint MerchantHistoric, address BuyerAddress, uint BuyerHistoric);
    event VoteNewMerchantContractApproval(address Voter, uint MerchantContractID);
    event NewMerchantContractApproved(uint MerchantContractID);
}