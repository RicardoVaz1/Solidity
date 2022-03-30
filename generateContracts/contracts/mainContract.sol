// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.8.0 <0.9.0;

import "./Libraries.sol";
import "./merchantContract.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract MainContract is Initializable {
    // VARIABLES
    using Address for address payable;
    

    /* ----- SYSTEM ----- */
    bool private initialized; // To prevent this contract from being initialized multiple times
    
    address private owner_address; // Owner of DApp (could be a DAO)

    bool public paused; // true = paused; false = unpaused

    event PausedSystem(uint256 Date, bool System_State); // true = paused; false = unpaused
    event OwnershipTransferred(uint256 Date, address Owner_Address, address New_Owner);


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
    
    mapping (uint => address) merchantsAccounts_Addresses;
    mapping (address => uint256) merchantsAccounts_Balances;
    mapping (address => string) merchantsAccounts_Names;
    mapping (address => bool) merchantsAccounts_States; // true = paused; false = unpaused
    uint256 merchantsAccounts_Counter;
    
    event PausedMerchant(uint256 Date, address Merchant_Address, bool System_State); // true = paused; false = unpaused
    event RemovedMerchant(uint256 Date, address Merchant_Address);
    event CreateMerchantContract(uint256 Date, address Merchant_Address, uint Merchant_Balance, string Merchant_Name, bool Merchant_State);
    /* --------------------- */



    // FUNCTIONS
    /*constructor() {
        owner_address = msg.sender;
        paused = false;
        merchantsAccounts_Counter = 0;
    }*/

    function initialize(address admin) public initializer {
        // This function is only used once (when we deploy MainContract)
        
        require(!initialized, "Contract instance has already been initialized"); // To prevent this contract from being initialized multiple times
        initialized = true;

        owner_address = admin;
        paused = false;
        merchantsAccounts_Counter = 0;
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

    function pauseSystem() public onlyOwner {
        paused = true;

        // Pause All Merchants
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            merchantsAccounts_States[merchantsAccounts_Addresses[i]] = paused;
            merchant.pauseMerchant(msg.sender);
            console.log("Merchant ", i+1, " Paused: ", merchantsAccounts_Addresses[i]);
            console.log("\n");
        }
        
        console.log("System is paused!");
        emit PausedSystem(block.timestamp, paused);
    }

    function unpauseSystem() public onlyOwner {
        paused = false;

        // Unpause All Merchants
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            merchantsAccounts_States[merchantsAccounts_Addresses[i]] = paused;
            merchant.pauseMerchant(msg.sender);
            console.log("Merchant ", i+1, " Unpaused: ", merchantsAccounts_Addresses[i]);
            console.log("\n");
        }

        console.log("System is unpaused!");
        emit PausedSystem(block.timestamp, paused);
    }

    function transferOwnership(address New_Owner) public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, New_Owner);
        owner_address = New_Owner;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }
    /* ------------------ */




    /* ----- MERCHANTs ----- */
    function pauseMerchant(address Merchant_Address) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(Merchant_Address == merchantsAccounts_Addresses[i]) {
                merchantsAccounts_States[Merchant_Address] = true;
                merchant.pauseMerchant(msg.sender);
                console.log("Merchant Paused: ", Merchant_Address);
                return;
            }
        }
        console.log("This Address doesn't exists in the system!");
        emit PausedMerchant(block.timestamp, Merchant_Address, true);
    }

    function unpauseMerchant(address Merchant_Address) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(Merchant_Address == merchantsAccounts_Addresses[i]) {
                merchantsAccounts_States[Merchant_Address] = false;
                merchant.unpauseMerchant(msg.sender);
                console.log("Merchant Unpaused: ", Merchant_Address);
                return;
            }
        }
        console.log("This Address doesn't exists in the system!");
        emit PausedMerchant(block.timestamp, Merchant_Address, false);
    }

    function removeMerchant(address Merchant_Address) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(Merchant_Address == merchantsAccounts_Addresses[i]) {
                merchant.pauseMerchant(msg.sender);
                delete merchantsAccounts_Addresses[i];
                merchant.deleteMerchant(msg.sender);
                console.log("Merchant Removed: ", Merchant_Address);
                return;
            }
        }
        console.log("This Address doesn't exists in the system!");
        emit RemovedMerchant(block.timestamp, Merchant_Address);
    }

    function addMerchant(address Merchant_Address, uint256 Merchant_Balance, string memory Merchant_Name) public onlyOwner systemState {
        require(Merchant_Address != owner_address, "That's the Owner Address!");

        if(verifyMerchantAddress(Merchant_Address) != true) return;

        merchant = new MerchantContract(owner_address, Merchant_Address, Merchant_Balance, Merchant_Name, false);
        
        merchantsAccounts_Addresses[merchantsAccounts_Counter] = Merchant_Address;
        merchantsAccounts_Balances[Merchant_Address] = Merchant_Balance;
        merchantsAccounts_Names[Merchant_Address] = Merchant_Name;
        merchantsAccounts_States[Merchant_Address] = false;

        console.log("Created new Merchant!");
        console.log("Address: ", Merchant_Address);
        console.log("Address: ", Merchant_Balance);
        console.log("Name: ", Merchant_Name);
        console.log("State: Unpaused");
        
        merchantsAccounts_Counter += 1;

        emit CreateMerchantContract(block.timestamp, Merchant_Address, Merchant_Balance, Merchant_Name, false);        
    }

    function verifyMerchantAddress(address Merchant_Address) view private returns(bool) {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(Merchant_Address == merchantsAccounts_Addresses[i]) {
                console.log("This Address already exists in the system!");
                return false;
            }
        }
        console.log("Merchant verified!");
        return true;
    }

    function getAllMerchantsInfo() view public onlyOwner {
        console.log("Total of Merchants: ", merchantsAccounts_Counter);
        console.log("\n");
        
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            console.log("Merchant ", i+1);
            console.log("Address: ", merchantsAccounts_Addresses[i]);
            console.log("Balance: ", merchantsAccounts_Balances[merchantsAccounts_Addresses[i]]);
            console.log("Name: ", merchantsAccounts_Names[merchantsAccounts_Addresses[i]]);
            console.log("State: ", merchantsAccounts_States[merchantsAccounts_Addresses[i]] == true ? "Paused" : "Unpaused");
            console.log("--------------");
        }
    }

    function balanceOf(address Account_Address) public view onlyOwner systemState returns (uint256) {
        console.log("Account: ", Account_Address);
        console.log("Balance: ", merchantsAccounts_Balances[Account_Address]);

        return merchantsAccounts_Balances[Account_Address];
    }
    /* --------------------- */
}