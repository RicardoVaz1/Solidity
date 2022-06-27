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
        MerchantContract merchantContract;   // buyers will be sending the money to this address
        string name;
        uint status; // 0: default, Merchant doesn't exist; 1: Merchant exist, but not approved; 2: Merchant exist and approved
        uint votes;
    }

    uint merchantsCounter; // count the nº of merchants
    mapping(uint => Merchant) public merchants;



    struct Votes {
        address MerchantContractAddress;
        bool voted; // false: didn't vote; true: already voted
    }

    // msg.sender => Votes
    mapping(address => Votes) public saveVoters;

    /*struct Votes {
        address Voter;
        bool voted; // false: didn't vote; true: already voted
    }

    // MerchantContractAddress => Votes
    mapping(address => Votes) public saveVoters;*/



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
        // Merchant { MerchantContract merchantContract, string name, uint status, uint votes }
        MerchantContract merchantContract = new MerchantContract(MerchantAddress, MerchantName);
        merchants[merchantsCounter] = Merchant(merchantContract, MerchantName, 1, 0);

        console.log("Created new Merchant!");
        console.log("MerchantContract Address: ", address(merchantContract));
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);
        
        freezeWithdrawalsMerchantContract(merchantsCounter);

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

    function voteNewMerchantContractApproval(uint MerchantContractID) public {
        if(merchants[MerchantContractID].status == 0) revert("Merchant doesn't exist!");
        // if(merchants[MerchantContractID].status == 1) revert("Merchant exist but not approved!");
        if(merchants[MerchantContractID].status == 2) revert("Merchant has already been approved!");

        address MerchantContractAddress = address(merchants[MerchantContractID].merchantContract);
        if(saveVoters[msg.sender].MerchantContractAddress == MerchantContractAddress && saveVoters[msg.sender].voted == true) revert("This address has already voted!");
        // if(saveVoters[MerchantContractAddress].Voter == msg.sender && saveVoters[MerchantContractAddress].voted == true) revert("This address has already voted!");

        uint voterHistoric = getVoterHistoric(msg.sender);

        if(voterHistoric != 0) {
            if(voterHistoric <= 10) merchants[MerchantContractID].votes += (voterHistoric*voterHistoric);
            else merchants[MerchantContractID].votes += 100;
        }
        else merchants[MerchantContractID].votes += 1;

        saveVoters[msg.sender].MerchantContractAddress = MerchantContractAddress;
        saveVoters[msg.sender].voted = true;
        // saveVoters[MerchantContractAddress].Voter = msg.sender;
        // saveVoters[MerchantContractAddress].voted = true;

        console.log("MerchantID: ", MerchantContractID);
        console.log("Merchant Address: ", MerchantContractAddress);
        console.log("Total of votes: ", merchants[MerchantContractID].votes);

        // From | To
        emit VoteNewMerchantContractApproval(msg.sender, MerchantContractAddress);

        if(merchants[MerchantContractID].votes > 1000) {
            merchants[MerchantContractID].status = 2;
            console.log("Merchant Address ", MerchantContractAddress, " has been approved!");

            unfreezeWithdrawalsMerchantContract(MerchantContractID);

            // NewMerchantContractApproved
            emit NewMerchantContractApproved(MerchantContractAddress);
        }
    }

    function getVoterHistoric(address VoterAddress) private view returns(uint) {
        uint voterHistoric = 0;

        for(uint i = 0; i < merchantsCounter; i++) {
            if(merchants[i].merchantContract.getMerchantHistoric(VoterAddress) != 0) {
                voterHistoric += merchants[i].merchantContract.getMerchantHistoric(VoterAddress);
            }
            else if(merchants[i].merchantContract.getBuyerHistoric(VoterAddress) != 0) {
                voterHistoric += merchants[i].merchantContract.getBuyerHistoric(VoterAddress);
            }
        }

        return voterHistoric;
    }



    /* ========== EVENTS ========== */
    event CreateMerchantContract(uint ID, address MerchantContractAddress, address MerchantAddress, string MerchantName);
    event PausedMerchantContract(address MerchantContractAddress, bool SystemState); // true = paused; false = unpaused
    event ApproveMerchant(address MerchantAddress);
    event ApproveBuyer(address BuyerAddress);
    event VoteNewMerchantContractApproval(address Voter, address MerchantContractAddress);
    event NewMerchantContractApproved(address MerchantContractAddress);
}