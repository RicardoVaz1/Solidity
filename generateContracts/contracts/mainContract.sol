// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./merchantContract.sol";
import "hardhat/console.sol";

contract MainContract {
    /* ========== SYSTEM ========== */
    address private owner_address;

    // bool teste;

    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }



    /* ========== MERCHANTs ========== */
    struct Merchant {
        MerchantContract merchantContract;   // buyers will be sending the money to this address
        string name;
        uint status; // 0: default, Merchant doesn't exist; 1: Merchant exist, but not approved; 2: Merchant exist and approved
        uint votes;
    }

    uint merchantsCounter; // count the nº of merchants
    mapping(uint => Merchant) public merchants;
    mapping(address => Merchant) public merchants2;


    struct Votes {
        bool voted; // false: didn't vote; true: already voted
    }

    // msg.sender => (MerchantContractAddress => Votes)
    mapping(address => mapping(address => Votes)) saveVoters;

    // Historic
    struct MerchantHistoric {
        uint Sells;
        uint Refunds;
    }

    // MerchantAddress => MerchantHistoric
    mapping(address => MerchantHistoric) private merchantHistoric;


    struct BuyersHistoric {
        uint Purchases;
        uint Cancellations;
    }

    // BuyerAddress => BuyersHistoric
    mapping(address => BuyersHistoric) private buyersHistoric;



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
    function getMerchantAddress(uint MerchantContractID) public view onlyOwner returns(address) {
        address merchant_address = merchants[MerchantContractID].merchantContract.getMerchantAddress();
        console.log("Merchant Address: ", merchant_address, "!!");
        return merchant_address;
    }

    function addMerchantContract(address payable MerchantAddress, string memory MerchantName) public onlyOwner {
        // Merchant { MerchantContract merchantContract, string name, uint status, uint votes }
        MerchantContract merchantContract = new MerchantContract(MerchantAddress, MerchantName);
        merchants[merchantsCounter] = Merchant(merchantContract, MerchantName, 1, 0);

        console.log("Created new Merchant!");
        console.log("MerchantContract Address: ", address(merchantContract));
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);        

        emit CreateMerchantContract(merchantsCounter, address(merchantContract), MerchantAddress, MerchantName);
        merchantsCounter++;
    }

    function approveMerchantContract(uint MerchantContractID) private {
        merchants[MerchantContractID].merchantContract.approveMerchant();

        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " Approved!");
        emit ApprovedMerchantContract(address(merchants[MerchantContractID].merchantContract), true);
    }

    function disapproveMerchantContract(uint MerchantContractID) public onlyOwner {
        if(merchants[MerchantContractID].status != 2) revert("This address isn't approved!");

        merchants[MerchantContractID].status = 1;
        merchants[MerchantContractID].merchantContract.disapproveMerchant();

        address MerchantContractAddress = address(merchants[MerchantContractID].merchantContract);
        console.log("Merchant Address ", MerchantContractAddress, " has been disapproved!");
        emit ApprovedMerchantContract(MerchantContractAddress, false);
    }

    function freezeWithdrawalsMerchantContract(uint MerchantContractID) public onlyOwner {
        merchants[MerchantContractID].merchantContract.pauseWithdrawals();

        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " Paused!");
        emit PausedMerchantContract(address(merchants[MerchantContractID].merchantContract), true);
    }

    function unfreezeWithdrawalsMerchantContract(uint MerchantContractID) public onlyOwner {
        merchants[MerchantContractID].merchantContract.unpauseWithdrawals();

        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " Unpaused!");
        emit PausedMerchantContract(address(merchants[MerchantContractID].merchantContract), false);
    }

    function voteNewMerchantContractApproval(uint MerchantContractID) public {
        if(merchants[MerchantContractID].status == 0) revert("Merchant doesn't exist!");
        // if(merchants[MerchantContractID].status == 1) revert("Merchant exist but not approved!");
        if(merchants[MerchantContractID].status == 2) revert("Merchant has already been approved!");

        address MerchantContractAddress = address(merchants[MerchantContractID].merchantContract);

        if(saveVoters[msg.sender][MerchantContractAddress].voted == true) revert("This address has already voted in this MerchantContract!");

        uint MerchantVotingPower = sqrt(merchantHistoric[msg.sender].Sells) - merchantHistoric[msg.sender].Refunds;
        uint BuyerVotingPower = sqrt(buyersHistoric[msg.sender].Purchases) - buyersHistoric[msg.sender].Cancellations;

        if(MerchantVotingPower != 0) {
            if(MerchantVotingPower <= 10) merchants[MerchantContractID].votes += MerchantVotingPower;
            else merchants[MerchantContractID].votes += 100;
        }
        // else merchants[MerchantContractID].votes += 1;

        if(BuyerVotingPower != 0) {
            if(BuyerVotingPower <= 10) merchants[MerchantContractID].votes += BuyerVotingPower;
            else merchants[MerchantContractID].votes += 100;
        }
        // else merchants[MerchantContractID].votes += 1;

        saveVoters[msg.sender][MerchantContractAddress].voted = true;

        console.log("MerchantContractID: ", MerchantContractID);
        console.log("Merchant Address: ", MerchantContractAddress);
        console.log("Total of votes: ", merchants[MerchantContractID].votes);

        // Voter | MerchantContract
        emit VoteNewMerchantContractApproval(msg.sender, MerchantContractAddress);

        if(merchants[MerchantContractID].votes > 5000) {
            merchants[MerchantContractID].status = 2;
            console.log("Merchant Address ", MerchantContractAddress, " has been approved!");

            approveMerchantContract(MerchantContractID);

            // NewMerchantContractApproved
            emit NewMerchantContractApproved(MerchantContractAddress);
        }
    }

    function saveHistoric(address MerchantAddress, address BuyerAddress, uint PurchaseStatus) public {
        /*teste = true;
        console.log("teste: ", teste);

        console.log("Msg.sender 2 is: ", msg.sender);
        console.log("MainContract address: ", address(this));*/

        address MerchantContractAddress = address(merchants2[msg.sender].merchantContract);
        uint MerchantContractStatus = merchants2[msg.sender].status;

        if(msg.sender != MerchantContractAddress && MerchantContractStatus != 2) revert("This address isn't approved!");

        if(PurchaseStatus == 0) {
            // purchase completed
            merchantHistoric[MerchantAddress].Sells += 1;
            buyersHistoric[BuyerAddress].Purchases += 1;
        }
        else {
            // purchase refunded
            merchantHistoric[MerchantAddress].Refunds += 1;
            buyersHistoric[BuyerAddress].Cancellations += 1;
        }

        // MerchantContractAddress | MerchantSells | MerchantRefunds | BuyerPurchases | BuyerCancellations
        emit SaveHistoric(address(this), merchantHistoric[MerchantAddress].Sells, merchantHistoric[MerchantAddress].Refunds, buyersHistoric[BuyerAddress].Purchases, buyersHistoric[BuyerAddress].Cancellations);
    }

    function sqrt(uint x) private view returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        console.log("y = ", y);
    }



    /* ========== Tests ========== */
    function MerchantContractCreatePurchase(uint MerchantContractID, uint idPurchase, uint256 purchaseAmount, uint escrowTime) public {
        merchants[MerchantContractID].merchantContract.createPurchase(idPurchase, purchaseAmount, escrowTime);
        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " - purchase created!");
    }

    function MerchantContractBuy(uint MerchantContractID, uint idPurchase) public {
        merchants[MerchantContractID].merchantContract.buy(idPurchase);
        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " - purchase paid!");
    }

    function MerchantContractHistoric(uint MerchantContractID, address BuyerAddress, uint purchaseStatus) public {
        merchants[MerchantContractID].merchantContract.historic(BuyerAddress, purchaseStatus);
        console.log("MerchantContract ", address(merchants[MerchantContractID].merchantContract), " - historic saved!");
    }


    /* ========== EVENTS ========== */
    event CreateMerchantContract(uint ID, address MerchantContractAddress, address MerchantAddress, string MerchantName);
    event PausedMerchantContract(address MerchantContractAddress, bool Paused); // true = paused; false = unpaused
    event ApprovedMerchantContract(address MerchantContractAddress, bool Approved); // true = approved; false = not approved
    event VoteNewMerchantContractApproval(address Voter, address MerchantContractAddress);
    event NewMerchantContractApproved(address MerchantContractAddress);
    event SaveHistoric(address MerchantContractAddress, uint Sells, uint Refunds, uint Purchases, uint Cancellations);
}