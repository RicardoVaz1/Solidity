// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

// import "./Libraries.sol";
import "./merchantContract.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract MainContract is Initializable {
    // using Address for address payable;

    /* ========== SYSTEM ========== */
    bool private initialized; // To prevent this contract from being initialized multiple times
    address private owner_address; // Owner of DApp (could be a DAO)
    bool public paused; // true = paused; false = unpaused

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



    /* ========== MERCHANTs ========== */
    uint merchantsCounter;
    mapping (uint => MerchantContract) public MerchantContracts;



    /* ========== CONSTRUCTOR ========== */
    /*constructor() {
        owner_address = msg.sender;
        paused = false;
        merchantsCounter = 0;
    }*/

    function initialize(address admin) public initializer {
        // This function is only used once (when we deploy MainContract)
        require(!initialized, "Contract instance has already been initialized"); // To prevent this contract from being initialized multiple times
        initialized = true;

        owner_address = admin;
        paused = false;
        merchantsCounter = 0;
    }
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}



    /* ========== SYSTEM ========== */
    function getOwnerAddress() public view onlyOwner returns(address) {
        console.log("Owner Address: ", owner_address);
        return owner_address;
    }

    function pauseSystem() public onlyOwner {
        paused = true;

        // Pause All Merchants
        for(uint i = 0; i < merchantsCounter; i++) {
            MerchantContracts[i].pauseMerchant();
            // console.log("Merchant ", MerchantContracts[i], " Paused!\n");
        }
        
        console.log("System is paused!");
        emit PausedSystem(paused);
    }

    function unpauseSystem() public onlyOwner {
        paused = false;

        // Unpause All Merchants
        for(uint i = 0; i < merchantsCounter; i++) {
            MerchantContracts[i].unpauseMerchant();
            // console.log("Merchant ", MerchantContracts[i], " Unpaused!\n");
        }

        console.log("System is unpaused!");
        emit PausedSystem(paused);
    }

    function transferOwnership(address NewOwner) public virtual onlyOwner systemState {
        emit OwnershipTransferred(owner_address, NewOwner);
        owner_address = NewOwner;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public virtual onlyOwner systemState {
        emit OwnershipTransferred(owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }



    /* ========== MERCHANTs ========== */
    function addMerchant(address MerchantAddress, string memory MerchantName) public onlyOwner systemState {
        require(MerchantAddress != owner_address, "That's the Owner Address!");

        bool merchant_exist;

        for(uint i = 0; i < merchantsCounter; i++) {
            if(MerchantAddress == MerchantContracts[i].getMerchantAddress()) {
                merchant_exist = true;
            }
        }

        if(merchant_exist == false) {
            merchantsCounter++;
            MerchantContracts[merchantsCounter] = new MerchantContract(owner_address, MerchantAddress, MerchantName);

            console.log("Created new Merchant!");
            console.log("Address: ", MerchantAddress);
            console.log("Name: ", MerchantName);

            emit CreateMerchantContract(MerchantAddress, MerchantName);
        }
        else console.log("This Address already exists in the system!");
    }

    function getMerchantID(address MerchantAddress) private view returns(uint) {
        uint id;
        for(uint i = 0; i < merchantsCounter; i++) {
            if(MerchantAddress == MerchantContracts[i].getMerchantAddress()) {
                id = i;
            }
        }
        return id;
    }

    function pauseMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        uint MerchantContractID = getMerchantID(MerchantAddress);
        MerchantContracts[MerchantContractID].pauseMerchant();
        console.log("Merchant ", MerchantAddress, " Paused!");
        emit PausedMerchant(MerchantAddress, true);
    }

    function unpauseMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        uint MerchantContractID = getMerchantID(MerchantAddress);
        MerchantContracts[MerchantContractID].unpauseMerchant();
        console.log("Merchant ", MerchantAddress, " Unpaused!");
        emit PausedMerchant(MerchantAddress, false);
    }

    function removeMerchant(address MerchantAddress) public virtual onlyOwner systemState {
        uint MerchantContractID = getMerchantID(MerchantAddress);
        console.log("Merchant ", MerchantAddress, " Removed!");
        emit RemovedMerchant(MerchantAddress);        
        MerchantContracts[MerchantContractID].deleteMerchant();
        delete MerchantContracts[MerchantContractID];
    }



    /* ========== EVENTS ========== */
    event PausedSystem(bool SystemState); // true = paused; false = unpaused
    event OwnershipTransferred(address OwnerAddress, address NewOwner);

    event CreateMerchantContract(address MerchantAddress, string MerchantName);
    event PausedMerchant(address MerchantAddress, bool SystemState); // true = paused; false = unpaused
    event RemovedMerchant(address MerchantAddress);
}