//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract{
    string public functionCalled;

    function sendEther() external payable {
        if(msg.value == 0 wei) {
            revert("Value should be grater than 0!");
        }
        functionCalled = "sendEther";
    }
    
    // function() external payable {
    //     functionCalled = 'fallback';
    // }
}