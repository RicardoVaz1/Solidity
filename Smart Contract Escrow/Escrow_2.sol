// "SPDX-License-Identifier: UNLICENSED"

pragma solidity >=0.7.0 <0.9.0;

contract Escrow {

    // VARIABLES
    enum State { NOT_INITIATED, AWAITING_PAYMENT, WAIT_A_MOMENT, COMPLETE }

    State public currsState;

    bool public isBuyerIn;
    bool public isMerchantIn;

    uint price;

    address buyer;
    address payable merchant;

    uint256 lastRun;

    uint256 startingTime;
    uint256 endingTime;



    // MODIFIERS
    modifier onlyBuyer () {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier escrowNotStarted() {
        require(currsState == State.NOT_INITIATED);
        _;
    }



    // FUNCTIONS
    constructor(address buyer_address, address payable merchant_address, uint product_price){
        buyer = buyer_address;
        merchant = merchant_address;
        price = product_price * (1 ether);
    }

    function initContract () escrowNotStarted public {
        if(msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == merchant) {
            isMerchantIn = true;
        }
        if (isBuyerIn && isMerchantIn) {
            currsState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() onlyBuyer public payable {
        require(currsState == State.AWAITING_PAYMENT, "Already paid");
        require(msg.value == price, "Wrong deposit amount");
        currsState = State.WAIT_A_MOMENT;
        
        //require(block.timestamp - lastRun > 1 minutes, 'Need to wait 1 minute'); // https://stackoverflow.com/questions/68024206/run-solidity-code-after-every-x-amount-of-time
        //timer();
        
        startingTime = block.timestamp;
        endingTime = startingTime + 60; // 1 minute

        require(block.timestamp >= endingTime);

        transactionSucess();
        //lastRun = block.timestamp;
    }

    /*function confirmDelivery() onlyBuyer payable public {
        require(currsState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        merchant.transfer(price);
        currsState = State.COMPLETE;
    }

    function withdraw() onlyBuyer payable public {
        require(currsState == State.AWAITING_DELIVERY, "Cannot withdraw at this stage");
        payable(msg.sender).transfer(price);
        currsState = State.COMPLETE;
    }

    function timer() public {
        require(block.timestamp - lastRun > 1 minutes, 'Need to wait 1 minutes');

        // TODO perform the action

        lastRun = block.timestamp;
    }*/

    function transactionSucess() payable public {
        merchant.transfer(price);
        currsState = State.COMPLETE;
    }
}