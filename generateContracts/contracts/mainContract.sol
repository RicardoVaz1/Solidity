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
    uint public merchantsCounter;
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

    function updateMerchantContracts(bool Pause) private {
        console.log("Pause: ", Pause);

        // Upadate All MerchantContracts
        for(uint i = 1; i <= merchantsCounter; i++) {
            if(Pause == true) {
                MerchantContracts[i].pauseMerchant();
                console.log("MerchantContract ", address(MerchantContracts[i]), " paused!\n");    
            }
            else {
                MerchantContracts[i].unpauseMerchant();
                console.log("MerchantContract ", address(MerchantContracts[i]), " paused!\n");    
            }
        }
    }

    function pauseSystem() public onlyOwner {
        paused = true;
        updateMerchantContracts(paused);
        
        console.log("System is paused!");
        emit PausedSystem(paused);
    }

    function unpauseSystem() public onlyOwner {
        paused = false;
        updateMerchantContracts(paused);

        console.log("System is unpaused!");
        emit PausedSystem(paused);
    }

    function transferOwnership(address NewOwner) public onlyOwner systemState {
        emit OwnershipTransferred(owner_address, NewOwner);
        owner_address = NewOwner;
        console.log("New Owner address is: ", owner_address);
    }

    function renounceOwnership() public onlyOwner systemState {
        emit OwnershipTransferred(owner_address, address(0));
        owner_address = address(0);
        console.log("Owner doesn't exist anymore!");
    }



    /* ========== MERCHANT_CONTRACTs ========== */
    function addMerchantContract(address MerchantAddress, string memory MerchantName) public onlyOwner systemState {
        // require(MerchantAddress != owner_address, "That's the Owner Address!");
        
        // if(MerchantContracts[merchantsCounter].verifyMerchantAddress(MerchantAddress) == false) {
            merchantsCounter++;
            MerchantContracts[merchantsCounter] = new MerchantContract(owner_address, MerchantAddress, MerchantName);

            console.log("Created new Merchant!");
            console.log("Address: ", MerchantAddress);
            console.log("Name: ", MerchantName);

            emit CreateMerchantContract(MerchantAddress, MerchantName);
        // }
        // else console.log("This Address already exists in the system!");
    }

    function getMerchantContractID(address MerchantContractAddress) private view returns(uint) {
        uint id;
        for(uint i = 0; i <= merchantsCounter; i++) {
            if(MerchantContractAddress == address(MerchantContracts[i])) {
                id = i;
            }
        }
        return id;
    }

    function pauseMerchantContract(address MerchantContractAddress) public onlyOwner systemState {
        uint MerchantContractID = getMerchantContractID(MerchantContractAddress);
        MerchantContracts[MerchantContractID].pauseMerchant();
        
        console.log("MerchantContract ", MerchantContractAddress, " Paused!");
        emit PausedMerchantContract(MerchantContractAddress, true);
    }

    function unpauseMerchantContract(address MerchantContractAddress) public onlyOwner systemState {
        uint MerchantContractID = getMerchantContractID(MerchantContractAddress);
        MerchantContracts[MerchantContractID].unpauseMerchant();
        
        console.log("MerchantContract ", MerchantContractAddress, " Unpaused!");
        emit PausedMerchantContract(MerchantContractAddress, false);
    }

    function removeMerchantContract(address MerchantContractAddress) public onlyOwner systemState {
        uint MerchantContractID = getMerchantContractID(MerchantContractAddress);
        MerchantContracts[MerchantContractID].deleteMerchant();
        delete MerchantContracts[MerchantContractID];
        merchantsCounter--;

        console.log("MerchantContract ", MerchantContractAddress, " Removed!");
        emit RemovedMerchantContract(MerchantContractAddress);
    }



    /* ========== EVENTS ========== */
    event PausedSystem(bool SystemState); // true = paused; false = unpaused
    event OwnershipTransferred(address OwnerAddress, address NewOwner);

    event CreateMerchantContract(address MerchantContractAddress, string MerchantName);
    event PausedMerchantContract(address MerchantContractAddress, bool SystemState); // true = paused; false = unpaused
    event RemovedMerchantContract(address MerchantContractAddress);
}