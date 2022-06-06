//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract3 {
    function invest() external payable {
        if(msg.value < 1 ether) {
            revert();
        }
    }

    function balanceof()external view returns(uint){
        return address(this).balance;
    }
}
