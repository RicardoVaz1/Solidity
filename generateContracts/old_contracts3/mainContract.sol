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
    }

    uint merchantsCounter; // count the nº of merchants
    mapping(uint => Merchant) public merchants;



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

    function changeEscrowTime(uint MerchantID, uint NewEscrowTime) public onlyOwner {
        merchants[MerchantID].merchantContract.changeEscrowTime(NewEscrowTime);
        console.log("EscrowTime of MerchantID ", MerchantID);
        console.log(" changed to ", NewEscrowTime, "!!");
    }

    function addMerchantContract(address payable MerchantAddress, string memory MerchantName) public onlyOwner {
        MerchantContract merchantContract = new MerchantContract(/*owner_address,*/ MerchantAddress, MerchantName);
        merchants[merchantsCounter] = Merchant(merchantContract, MerchantName);

        console.log("Created new Merchant!");
        console.log("MerchantContract Address: ", address(merchantContract));
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);

        emit CreateMerchantContract(merchantsCounter, address(merchantContract), MerchantAddress, MerchantName);
        merchantsCounter++;
    }

    function pauseMerchantContract(uint MerchantID) public onlyOwner {
        merchants[MerchantID].merchantContract.pauseMerchant();
        
        console.log("MerchantContract ", address(merchants[MerchantID].merchantContract), " Paused!");
        emit PausedMerchantContract(address(merchants[MerchantID].merchantContract), true);
    }

    function unpauseMerchantContract(uint MerchantID) public onlyOwner {
        merchants[MerchantID].merchantContract.unpauseMerchant();
        
        console.log("MerchantContract ", address(merchants[MerchantID].merchantContract), " Unpaused!");
        emit PausedMerchantContract(address(merchants[MerchantID].merchantContract), false);
    }

    function removeMerchantContract(uint MerchantID) public onlyOwner {
        merchants[MerchantID].merchantContract.deleteMerchant();
        console.log("MerchantContract ", address(merchants[MerchantID].merchantContract), " Removed!");
        emit RemovedMerchantContract(address(merchants[MerchantID].merchantContract));
        delete merchants[MerchantID];
        merchantsCounter--;
    }



    /* ========== EVENTS ========== */
    event CreateMerchantContract(uint ID, address MerchantContractAddress, address MerchantAddress, string MerchantName);
    event PausedMerchantContract(address MerchantContractAddress, bool SystemState); // true = paused; false = unpaused
    event RemovedMerchantContract(address MerchantContractAddress);
}