// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

contract StructMapping {
    string public functionCalled;
    mapping(address => uint) public balanceReceived;

    function sendMoney() external payable {
        if(msg.value == 0) {
            revert("Value should be grater than 0!");
        }
        balanceReceived[msg.sender] += msg.value;
        functionCalled = "sendEther";
        address contractAddress = address(this);

        emit SendMoney(contractAddress, msg.sender, msg.value);

        console.log("Contract address: ", address(this));
        console.log("Address calling: ", msg.sender);
    }

    function getBalance() public returns(uint) {
        console.log("Contract address: ", address(this));
        console.log("Address calling: ", msg.sender);

        uint balance = address(this).balance;

        emit GetBalance(msg.sender, balance);
        
        return address(this).balance;
    }

    function withdrawAllMoney(address payable _to) public {
        uint balanceToSend = balanceReceived[msg.sender];

        if(balanceToSend == 0) {
            revert("Value should be grater than 0!");
        }
        balanceReceived[msg.sender] = 0;
        _to.transfer(balanceToSend);

        emit WithdrawAllMoney(msg.sender, _to, balanceToSend);

        console.log("Contract address: ", address(this));
        console.log("Address calling: ", msg.sender);
        console.log("Address _to: ", _to);
    }

    /* ========== EVENTS ========== */
    event SendMoney(address ContractAddress, address From, uint Ammount);
    event GetBalance(address From, uint Balance);
    event WithdrawAllMoney(address From, address To, uint Amount);
}