// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0 <0.9.0;

import "./Libraries.sol";
import "./merchantContract.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract MainContractV2 is Initializable {
    // VARIABLES
    using Address for address payable;
    

    /* ----- SYSTEM ----- */
    bool private initialized; // To prevent this contract from being initialized multiple times
    
    address private owner_address; // Owner of DApp (could be a DAO)

    bool public paused; // true = paused; false = unpaused

    event PausedSystem(uint256 Date, bool SystemState); // true = paused; false = unpaused
    event OwnershipTransferred(uint256 Date, address OwnerAddress, address NewOwner);


    function _only0wner() private view {
        // This way we reduce Solidity code size
        require(msg.sender == owner_address, "Only Owner can call this function");
    }

    function _systemState() private view {
        // This way we reduce Solidity code size
        require(paused == false, "The system is Paused!");
    }

    modifier onlyOwner() {
        _only0wner();
        _;
    }

    modifier systemState() {
        _systemState();
        _;
    }
    /* ------------------ */



    /* ----- MERCHANTs ----- */
    MerchantContract private merchant;
    
    mapping (uint => address) merchantsAddresses;
    uint256 merchantsCounter;
    
    event PausedMerchant(uint256 Date, address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event RemovedMerchant(uint256 Date, address MerchantAddress);
    event CreateMerchantContract(uint256 Date, address MerchantAddress, string MerchantName, bool MerchantState);
    /* --------------------- */



    // FUNCTIONS
    /*constructor() {
        owner_address = msg.sender;
        paused = false;
        merchantsCounter = 0;
    }*/

    function initialize(address admin) public initializer {
        // This function is only used for Upgrade Tests
        
        require(!initialized, "Contract instance has already been initialized"); // To prevent this contract from being initialized multiple times
        initialized = true;

        owner_address = admin;
        paused = false;
        merchantsCounter = 0;
    }
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}



    /* ----- SYSTEM ----- */
    function getOwnerAddress() view public returns(address) {
        // require(msg.sender == owner_address, "Only Owner can call this function");
        // If we uncomment the previous line (or add the "onlyOwner" modifier) when we tried to call the function from Hardhat console it won't work

        console.log("Owner Address: ", owner_address);
        return owner_address;
    }

    function getOwnerAddress2() onlyOwner view public returns(address) {
        console.log("Owner Address: ", owner_address);
        return owner_address;
    }

    function pauseSystem() public onlyOwner {
        paused = true;

        // Pause All Merchants
        for(uint i = 0; i < merchantsCounter; i++) {
            merchant.pauseMerchant(msg.sender);
            console.log("Merchant ", i+1, " Paused: ", merchantsAddresses[i]);
            console.log("\n");
        }
        
        console.log("System is paused!");
        emit PausedSystem(block.timestamp, paused);
    }

    function unpauseSystem() public onlyOwner {
        paused = false;

        // Unpause All Merchants
        for(uint i = 0; i < merchantsCounter; i++) {
            merchant.unpauseMerchant(msg.sender);
            console.log("Merchant ", i+1, " Unpaused: ", merchantsAddresses[i]);
            console.log("\n");
        }

        console.log("System is unpaused!");
        emit PausedSystem(block.timestamp, paused);
    }

    function transferOwnership(address NewOwner) public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, NewOwner);
        owner_address = NewOwner;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }
    /* ------------------ */




    /* ----- MERCHANTs ----- */
    function pauseMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        merchant.pauseMerchant(msg.sender);
        console.log("Merchant Paused: ", MerchantAddress);
        emit PausedMerchant(block.timestamp, MerchantAddress, true);
    }

    function unpauseMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        merchant.unpauseMerchant(msg.sender);
        console.log("Merchant Unpaused: ", MerchantAddress);
        emit PausedMerchant(block.timestamp, MerchantAddress, false);
    }

    function removeMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsCounter; i++) {
            if(MerchantAddress == merchantsAddresses[i]) {
                console.log("Merchant Removed: ", MerchantAddress);
                emit RemovedMerchant(block.timestamp, MerchantAddress);
                
                delete merchantsAddresses[i];
                merchant.deleteMerchant(msg.sender);
            }
        }        
    }

    function addMerchant(address MerchantAddress, string memory MerchantName) public onlyOwner systemState {
        require(MerchantAddress != owner_address, "That's the Owner Address!");

        for(uint i = 0; i < merchantsCounter; i++) {
            if(MerchantAddress == merchantsAddresses[i]) {
                console.log("This Address already exists in the system!");
                return;
            }
        }

        merchant = new MerchantContract(owner_address, MerchantAddress, MerchantName, false);
        
        merchantsAddresses[merchantsCounter] = MerchantAddress;

        console.log("Created new Merchant!");
        console.log("Address: ", MerchantAddress);
        console.log("Name: ", MerchantName);
        
        merchantsCounter += 1;

        emit CreateMerchantContract(block.timestamp, MerchantAddress, MerchantName, false);        
    }
    /* --------------------- */
}