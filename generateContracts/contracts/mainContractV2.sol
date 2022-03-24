// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;

import "./Libraries.sol";
import "./merchantContract.sol";
import "hardhat/console.sol";

contract MainContractV2 {
    // VARIABLES
    using SafeMath for uint256;
    using Address for address payable;
    

    /* ----- SYSTEM ----- */
    address private owner_address; // Owner of DApp (could be a DAO)

    uint public version;
    bool public system_state; // true = paused; false = unpased
    //address public implementation;

    event PausedSystem(uint256 DATE, bool SYSTEM_STATE); // true = paused; false = unpased
    event UnpausedSystem(uint256 DATE, bool SYSTEM_STATE);
    event OwnershipTransferred(uint256 DATE, address OWNER_ADDRESS, address NEW_OWNER);
    //event Upgrade(uint256 DATE, uint VERSION, address ADDRESS);


    modifier onlyOwner() {
        require(msg.sender == owner_address, "Only Owner can call this function");
        _;
    }

    modifier systemState() {
        require(system_state == false, "The system is Paused!");
        _;
    }
    /* ------------------ */



    /* ----- MERCHANTs ----- */
    MerchantContract private merchant;
    
    mapping (uint => address) merchantsAccounts_Addresses;
    mapping (address => uint256) merchantsAccounts_Balances;
    mapping (address => string) merchantsAccounts_Names;
    mapping (address => bool) merchantsAccounts_States; // true = paused; false = unpased
    uint256 merchantsAccounts_Counter;
    
    event PausedMerchant(uint256 DATE, address MERCHANT_ADDRESS, bool SYSTEM_STATE); // true = paused; false = unpased
    event UnpausedMerchant(uint256 DATE, address MERCHANT_ADDRESS, bool SYSTEM_STATE);
    event RemovedMerchant(uint256 DATE, address MERCHANT_ADDRESS);
    event CreateMerchantContract(uint256 DATE, address MERCHANT_ADDRESS, uint MERCHANT_BALANCE, string MERCHANT_NAME, bool MERCHANT_STATE);
    /* --------------------- */




    // FUNCTIONS
    /*constructor() {
        owner_address = msg.sender;
        system_state = false;
        version = 1.0;
        merchantsAccounts_Counter = 0;
    }*/

    function initial(uint256 COUNTER) public {
        // This function is only used for Upgrade Tests
        
        owner_address = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        system_state = false;
        version = 1;
        merchantsAccounts_Counter = COUNTER;
    }

    function getCounter() view public returns(uint256) {
        // This function is only used for Upgrade Tests

        console.log("Counter: ", merchantsAccounts_Counter);
        return merchantsAccounts_Counter;
    }

    function incrementCounter() public {
        // This function is only used for Upgrade Tests

        merchantsAccounts_Counter += 1;
        console.log("Counter: ", merchantsAccounts_Counter);
    }



    /* ----- SYSTEM ----- */
    function getOwnerAddress() onlyOwner view public returns(address) {        
        console.log("Owner Address: ", owner_address);
        return owner_address;
    }

    function pauseSystem() public onlyOwner {
        system_state = true;
        console.log("System is paused!");
        emit PausedSystem(block.timestamp, system_state);
    }

    function unpauseSystem() public onlyOwner {
        system_state = false;
        console.log("System is unpaused!");
        emit UnpausedSystem(block.timestamp, system_state);
    }

    function transferOwnership(address NEW_OWNER) public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, NEW_OWNER);
        owner_address = NEW_OWNER;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public virtual onlyOwner systemState {
        emit OwnershipTransferred(block.timestamp, owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }

    /*function upgradeSystem(address NEW_ADDRESS) public virtual onlyOwner systemState {
        version += 1;
        implementation = NEW_ADDRESS;
        emit Upgrade(block.timestamp, version, implementation);
        
        console.log("System Upgraded");
        console.log("Version: ", version);
        console.log("Address: ", NEW_ADDRESS);
        
        Link: https://www.youtube.com/watch?v=bdXJmWajZRY
    }*/
    /* ------------------ */




    /* ----- MERCHANTs ----- */
    function pauseMerchant(address MERCHANT_ADDRESS) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(MERCHANT_ADDRESS == merchantsAccounts_Addresses[i]) {
                merchantsAccounts_States[MERCHANT_ADDRESS] = true;
                merchant.pauseMerchant(owner_address);
                console.log("Merchant Paused: ", MERCHANT_ADDRESS);
                return;
            }
        }
        console.log("This Address doen't exists in the system!");
        emit PausedMerchant(block.timestamp, MERCHANT_ADDRESS, true);
    }

    function unpauseMerchant(address MERCHANT_ADDRESS) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(MERCHANT_ADDRESS == merchantsAccounts_Addresses[i]) {
                merchantsAccounts_States[MERCHANT_ADDRESS] = false;
                merchant.unpauseMerchant(owner_address);
                console.log("Merchant Unpaused: ", MERCHANT_ADDRESS);
                return;
            }
        }
        console.log("This Address doen't exists in the system!");
        emit UnpausedMerchant(block.timestamp, MERCHANT_ADDRESS, false);
    }

    function removeMerchant(address MERCHANT_ADDRESS) public virtual onlyOwner systemState {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(MERCHANT_ADDRESS == merchantsAccounts_Addresses[i]) {
                delete merchantsAccounts_Addresses[i];
                merchant.deleteMerchant(owner_address);
                console.log("Merchant Removed: ", MERCHANT_ADDRESS);
                return;
            }
        }
        console.log("This Address doen't exists in the system!");
        emit RemovedMerchant(block.timestamp, MERCHANT_ADDRESS);
    }

    function addMerchant(address MERCHANT_ADDRESS, uint256 MERCHANT_BALANCE, string memory MERCHANT_NAME) public onlyOwner systemState {
        require(MERCHANT_ADDRESS != owner_address, "That's the Owner Address!");

        if(verifyMerchantAddress(MERCHANT_ADDRESS) != true) return;

        merchant = new MerchantContract(owner_address, MERCHANT_ADDRESS, MERCHANT_BALANCE, MERCHANT_NAME, false);
        
        merchantsAccounts_Addresses[merchantsAccounts_Counter] = MERCHANT_ADDRESS;
        merchantsAccounts_Balances[MERCHANT_ADDRESS] = MERCHANT_BALANCE;
        merchantsAccounts_Names[MERCHANT_ADDRESS] = MERCHANT_NAME;
        merchantsAccounts_States[MERCHANT_ADDRESS] = false;

        console.log("Created new Merchant!");
        console.log("Address: ", MERCHANT_ADDRESS);
        console.log("Address: ", MERCHANT_BALANCE);
        console.log("Name: ", MERCHANT_NAME);
        console.log("State: Unpaused");
        
        merchantsAccounts_Counter += 1;

        emit CreateMerchantContract(block.timestamp, MERCHANT_ADDRESS, MERCHANT_BALANCE, MERCHANT_NAME, false);        
    }

    function verifyMerchantAddress(address MERCHANT_ADDRESS) view private returns(bool) {
        for(uint i = 0; i < merchantsAccounts_Counter; i++) {
            if(MERCHANT_ADDRESS == merchantsAccounts_Addresses[i]) {
                console.log("This Address already exists in the system!");
                return false;
            }
        }
        console.log("Merchant verified!");
        return true;
    }

    function getAllMerchantsInfo() view public onlyOwner systemState {
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

    function balanceOf(address ACCOUNT_ADDRESS) public view onlyOwner systemState returns (uint256) {
        console.log("Account: ", ACCOUNT_ADDRESS);
        console.log("Balance: ", merchantsAccounts_Balances[ACCOUNT_ADDRESS]);

        return merchantsAccounts_Balances[ACCOUNT_ADDRESS];
    }
    /* --------------------- */
}