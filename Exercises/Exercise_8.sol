// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Storage {
    //Exercise 8 - Storage (Store & retrieve value in a variable)

    uint256 number;

    //Store value in variable 'num'
    function store(uint256 num) public {
        number = num;
    }

    //Return value of 'number'
    function retrieve() public view returns (uint256){
        return number;
    }
}