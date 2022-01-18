//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract Token {
    string public name = "Rick Token";
    string public symbol = "R";
    uint public totalSupply = 1000000;
    mapping(address => uint) balances; //Equal to --> const balances = { address: uint }

    constructor() {
        //The balance of the person who deploy this contract it will be equal totalSupply
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint amount) external {
        // console.log("Erro aqui!");
        require(balances[msg.sender] >= amount, "Not enough tokens!");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
}