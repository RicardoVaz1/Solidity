// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;

import "./Libraries.sol";

abstract contract Escrow {
    // VARIABLES
    enum State { AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }
    State public currsState;

    address _buyerAddress;
    //address payable merchant;
    uint256 _amount;

    // Date | Transaction_Type | From | To | Value | Status
    event Deposited(uint256 date, string transactionType, address _buyerAddress, address _merchantAddress, uint256 amount, string status);
    event Sell(uint256 date, string transactionType, address _buyerAddress, address _merchantAddress, uint256 amount, string status);


    // FUNCTIONS
    constructor(address buyer_address, uint256 product_price) {
        _buyerAddress = buyer_address;
        _amount = product_price * (1 ether);
    }

    function _deposit(address _merchantAddress) public payable {
        require(currsState == State.AWAITING_PAYMENT, "Already paid");

        // Date | Transaction_Type | From | To | Value | Status
        emit Deposited(block.timestamp, "Deposit", _buyerAddress, _merchantAddress, _amount, "Complete");
        
        // Waiting x blocks before send the money to Merchant
        /* ... */

        currsState = State.WAIT_A_MOMENT;
        transactionSucess(_merchantAddress);
    }

    function transactionSucess(address _merchantAddress) private {
        require(currsState == State.WAIT_A_MOMENT, "Not in the correct stage!");
        payable(_merchantAddress).transfer(_amount);
        currsState = State.COMPLETE;

        // Date | Transaction_Type | From | To | Value | Status
        emit Sell(block.timestamp, "Sell", _buyerAddress, _merchantAddress, _amount, "Complete");
    }
}


abstract contract Refunds {
    // VARIABLES
    address _buyer_Address;
    uint256 _Amount;

    // Date | Transaction_Type | From | To | Value | Status
    event Refund(uint256 date, string transactionType, address _buyer_Address, address _merchantAddress, uint256 _Amount, string status);


    // FUNCTIONS
    constructor(address buyer_address, uint256 product_price){
        _buyer_Address = buyer_address;
        _Amount = product_price * (1 ether);
    }
    
    function _refund(address _merchantAddress) public {
        payable(_buyer_Address).transfer(_Amount);

        // Date | Transaction_Type | From | To | Value | Status
        emit Refund(block.timestamp, "Refund", _buyer_Address, _merchantAddress, _Amount, "Complete");
    }
}


abstract contract MerchantContract is Escrow, Refunds {
    address public merchant_address;

    modifier onlyMerchant() {
        require(msg.sender == merchant_address, "Only Merchant can call this function");
        _;
    }

    constructor(address _merchant_address) {
        merchant_address = _merchant_address;
    }

    function deposit() public virtual {
        _deposit(merchant_address);
    }

    function refund() public virtual onlyMerchant {
        _refund(merchant_address);
    }
}

abstract contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        //emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        //emit Unpaused(_msgSender());
    }
}


contract MainContract is MerchantContract, Pausable {
    using SafeMath for uint256;
    using Address for address payable;

    mapping (address => uint256) private _balances;

    address public owner; // Owner of DApp (could be a DAO)

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }
    
    constructor(address _owner) {
        owner = _owner;
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }
}