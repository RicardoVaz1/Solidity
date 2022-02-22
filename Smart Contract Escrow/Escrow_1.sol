// "SPDX-License-Identifier: UNLICENSED"

// Tutorial:
    // Parte 1 --> https://www.youtube.com/watch?v=xKdQv7tG8-k
    // Parte 2 --> https://www.youtube.com/watch?v=RsJfjH9f3AM

pragma solidity >=0.7.0 <0.9.0;

contract Escrow {

    // VARIABLES
    enum State { NOT_INITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    State public currsState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint public price;

    address public buyer;
    address payable public seller;

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
    constructor(address _buyer, address payable _seller, uint _price){
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    function initContract () escrowNotStarted public {
        if(msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == seller) {
            isSellerIn = true;
        }
        if (isBuyerIn && isSellerIn) {
            currsState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() onlyBuyer public payable {
        require(currsState == State.AWAITING_PAYMENT, "Already paid");
        require(msg.value == price, "Wrong deposit amount");
        currsState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() onlyBuyer payable public {
        require(currsState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        seller.transfer(price);
        currsState = State.COMPLETE;
    }

    function withdraw() onlyBuyer payable public {
        require(currsState == State.AWAITING_DELIVERY, "Cannot withdraw at this stage");
        payable(msg.sender).transfer(price);
        currsState = State.COMPLETE;
    }
}